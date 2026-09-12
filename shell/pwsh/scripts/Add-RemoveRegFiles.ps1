Param(
    [string]$Config = (Join-Path $PSScriptRoot "..\configs\reg_files.json"),
    [string[]]$Groups,
    [ValidateSet('add', 'remove')][string]$Action = 'add',
    [switch]$All,
    [switch]$ImportAdminOnly
)

function Flush-ConsoleInput {
    try {
        if ($Host.UI.RawUI.KeyAvailable) {
            while ($Host.UI.RawUI.KeyAvailable) {
                $null = [Console]::ReadKey($true)
            }
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }
    catch {}
}

function Expand-PercentVars {
    param([string]$s)
    return [regex]::Replace($s, '%([^%]+)%', { param($m)
            $name = $m.Groups[1].Value
            $envItem = Get-Item -Path ("Env:\" + $name) -ErrorAction SilentlyContinue
            if ($envItem) { return $envItem.Value } else { return $m.Value }
        })
}

function Get-ScoopRegEntries {
    $scoopDirs = @()
    if ($env:SCOOP -and (Test-Path "$env:SCOOP\apps")) { $scoopDirs += "$env:SCOOP\apps" }
    if (Test-Path "$env:USERPROFILE\scoop\apps") { $scoopDirs += "$env:USERPROFILE\scoop\apps" }
    if ($env:SCOOP_GLOBAL -and (Test-Path "$env:SCOOP_GLOBAL\apps")) { $scoopDirs += "$env:SCOOP_GLOBAL\apps" }
    if (Test-Path "$env:ProgramData\scoop\apps") { $scoopDirs += "$env:ProgramData\scoop\apps" }
    $scoopDirs = $scoopDirs | Select-Object -Unique

    $discovered = [ordered]@{}
    foreach ($appsDir in $scoopDirs) {
        $regFiles = Get-ChildItem -Path "$appsDir\*\current\*.reg" -ErrorAction SilentlyContinue
        foreach ($file in $regFiles) {
            $appName = $file.Directory.Parent.Name
            if (-not $discovered.Contains($appName)) {
                $discovered[$appName] = @{ add = @(); remove = @() }
            }
            if ($file.Name -match '(?i)uninstall|remove|disable') {
                $discovered[$appName].remove += $file.FullName
            }
            else {
                $discovered[$appName].add += $file.FullName
            }
        }
    }
    return $discovered
}

# Check elevation
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

# Resolve config path if provided
$configPath = $null
$configDir = $null
if ($Config) {
    if (Test-Path -LiteralPath $Config) {
        $configPath = (Resolve-Path -LiteralPath $Config).Path
    }
    else {
        $tryPath = Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -ChildPath $Config
        if (Test-Path -LiteralPath $tryPath) {
            $configPath = (Resolve-Path -LiteralPath $tryPath).Path
        }
    }
    if ($configPath) {
        $configDir = Split-Path $configPath -Parent
    }
}

# 1. Initialize registry entries from Scoop discovery
$allGroups = [ordered]@{}
$scoopEntries = Get-ScoopRegEntries
foreach ($app in $scoopEntries.Keys) {
    $allGroups[$app] = [PSCustomObject]@{
        enabled = $true
        add     = [System.Collections.Generic.List[string]]::new([string[]]$scoopEntries[$app].add)
        remove  = [System.Collections.Generic.List[string]]::new([string[]]$scoopEntries[$app].remove)
    }
}

# 2. Merge JSON config file if present (for overrides or custom non-Scoop registry files)
if ($configPath -and (Test-Path -LiteralPath $configPath)) {
    try {
        $json = Get-Content -Raw -LiteralPath $configPath -ErrorAction Stop | ConvertFrom-Json
        if ($json -is [PSCustomObject]) {
            foreach ($prop in $json.PSObject.Properties) {
                $name = $prop.Name
                $val = $prop.Value
                $isEnabled = $true

                if ($val -is [PSCustomObject]) {
                    if ($val.PSObject.Properties.Name -contains 'enabled' -and $val.enabled -eq $false) {
                        $isEnabled = $false
                    }
                }

                if (-not $allGroups.Contains($name)) {
                    $allGroups[$name] = [PSCustomObject]@{
                        enabled = $isEnabled
                        add     = [System.Collections.Generic.List[string]]::new()
                        remove  = [System.Collections.Generic.List[string]]::new()
                    }
                }
                else {
                    $allGroups[$name].enabled = $isEnabled
                }

                if ($val -is [PSCustomObject]) {
                    foreach ($act in @('add', 'remove')) {
                        if ($val.PSObject.Properties.Name -contains $act -and $val.$act) {
                            foreach ($p in $val.$act) {
                                $expanded = Expand-PercentVars $p
                                if (-not [System.IO.Path]::IsPathRooted($expanded)) { $expanded = Join-Path $configDir $expanded }
                                $resolved = Resolve-Path -LiteralPath $expanded -ErrorAction SilentlyContinue
                                $pathToAdd = if ($resolved) { $resolved.Path } else { $expanded }
                                if (-not $allGroups[$name].$act.Contains($pathToAdd)) {
                                    $allGroups[$name].$act.Add($pathToAdd)
                                }
                            }
                        }
                    }
                }
                elseif ($val -is [System.Array]) {
                    foreach ($p in $val) {
                        $expanded = Expand-PercentVars $p
                        if (-not [System.IO.Path]::IsPathRooted($expanded)) { $expanded = Join-Path $configDir $expanded }
                        $resolved = Resolve-Path -LiteralPath $expanded -ErrorAction SilentlyContinue
                        $pathToAdd = if ($resolved) { $resolved.Path } else { $expanded }
                        if (-not $allGroups[$name].add.Contains($pathToAdd)) {
                            $allGroups[$name].add.Add($pathToAdd)
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to parse JSON in $($configPath): $($_.Exception.Message)"
    }
}

# Determine execution mode: interactive vs scripted
$hasExplicitGroups = $PSBoundParameters.ContainsKey('Groups') -and $Groups.Count -gt 0
$hasExplicitAction = $PSBoundParameters.ContainsKey('Action')
$hasGum = [bool](Get-Command gum -ErrorAction SilentlyContinue)
$isInteractive = [Environment]::UserInteractive -and -not $ImportAdminOnly -and $hasGum -and -not [Console]::IsInputRedirected

$selectedGroups = @{}

if ($isInteractive -and -not $hasExplicitGroups -and -not $All) {
    # 1. Interactive Action Selection if not provided
    if (-not $hasExplicitAction) {
        $actionChoice = gum choose --header="Select Action:" --header.foreground="39" --cursor="> " --cursor.foreground="39" "Add (Import to Registry)" "Remove (Revert from Registry)"
        Flush-ConsoleInput
        if (-not $actionChoice) { return }
        $Action = if ($actionChoice -like "Add*") { "add" } else { "remove" }
    }

    # 2. Get available groups that have reg files for this action
    $availableGroups = @()
    foreach ($g in $allGroups.Keys) {
        if ($allGroups[$g].enabled -ne $false -and $allGroups[$g].$Action.Count -gt 0) {
            $availableGroups += $g
        }
    }

    if ($availableGroups.Count -eq 0) {
        Write-Host "[-] No registry files found for action: $Action" -ForegroundColor Yellow
        return
    }

    # 3. Present multi-select menu via Gum
    $menuOptions = @()
    foreach ($g in $availableGroups) {
        $fileNames = ($allGroups[$g].$Action | ForEach-Object { Split-Path $_ -Leaf }) -join ', '
        $menuOptions += "$g ($fileNames)"
    }

    $headerText = if ($Action -eq 'add') { "Select registry tweaks to import (Space to toggle, Enter to confirm):" } else { "Select registry tweaks to revert (Space to toggle, Enter to confirm):" }
    $chosen = gum choose --no-limit --header=$headerText --header.foreground="39" --cursor-prefix="> " --selected-prefix="[x] " --unselected-prefix="[ ] " --cursor.foreground="39" --selected.foreground="42" $menuOptions
    Flush-ConsoleInput
    if (-not $chosen -or $chosen.Count -eq 0) { return }

    foreach ($c in $chosen) {
        if ($c -match '^(?<app>[^\s\(]+)') {
            $selectedGroups[$Matches['app']] = $true
        }
    }
}
elseif ($hasExplicitGroups) {
    foreach ($groupName in $Groups) {
        $selectedGroups[$groupName] = $true
    }
}
else {
    # Default non-interactive or -All: select all enabled groups for this action
    foreach ($g in $allGroups.Keys) {
        if ($allGroups[$g].enabled -ne $false -and $allGroups[$g].$Action.Count -gt 0) {
            $selectedGroups[$g] = $true
        }
    }
}

# Collect target entries to process
$entries = @()
foreach ($g in $selectedGroups.Keys) {
    if (-not $allGroups.Contains($g)) {
        Write-Warning "Group '$g' not found in discovered or configured registry entries."
        continue
    }
    $val = $allGroups[$g]
    foreach ($p in $val.$Action) {
        $entries += [pscustomobject]@{ Group = $g; Path = $p }
    }
}

# Categorize into admin-needed vs non-admin
$adminEntries = @()
$nonAdminEntries = @()
foreach ($entry in $entries) {
    $p = $entry.Path
    $group = $entry.Group
    if (-not $p) { continue }

    $fileResolved = Resolve-Path -LiteralPath $p -ErrorAction SilentlyContinue
    if (-not $fileResolved) { Write-Warning ".reg file not found: $p"; continue }
    $fullPath = $fileResolved.Path

    $content = Get-Content -Raw -ErrorAction SilentlyContinue -Path $fullPath
    $isAdminFile = $false
    if ($null -ne $content) {
        if ($content -match '(?mi)^\s*\[(?:HKEY_LOCAL_MACHINE|HKLM|HKEY_CLASSES_ROOT|HKCR|HKEY_USERS|HKU)\b') {
            $isAdminFile = $true
        }
    }

    if ($isAdminFile) { $adminEntries += [pscustomobject]@{ Path = $fullPath; Content = $content; Group = $group } }
    else { $nonAdminEntries += [pscustomobject]@{ Path = $fullPath; Content = $content; Group = $group } }
}

function Invoke-RegistryAction {
    param(
        [string]$Path,
        [string]$Action = 'add',
        [string]$Group = ''
    )
    try {
        & reg.exe import $Path *>$null
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE }
    }
    catch {
        Write-Error "Failed to execute registry action on $($Path): $($_.Exception.Message)"
        return [PSCustomObject]@{ ExitCode = 1 }
    }
}

function Apply-RegistryEntries {
    param(
        [pscustomobject[]]$Entries,
        [string]$Action = 'add',
        [bool]$Quiet = $false
    )

    if ($Entries.Count -eq 0) { return @() }

    $results = @()
    foreach ($item in $Entries) {
        $proc = Invoke-RegistryAction -Path $item.Path -Action $Action -Group $item.Group
        $fileName = Split-Path $item.Path -Leaf
        $isOk = ($null -ne $proc -and $proc.ExitCode -eq 0)
        $results += [PSCustomObject]@{
            Group   = $item.Group
            File    = $fileName
            Success = $isOk
        }
    }
    return $results
}

# If called with -ImportAdminOnly, import only admin entries and exit silently
if ($ImportAdminOnly) {
    $null = Apply-RegistryEntries -Entries $adminEntries -Action $Action -Quiet $true
    exit 0
}

$allResults = @()

# If admin entries exist and we are not elevated, launch elevated helper for admin items
if ($adminEntries.Count -gt 0 -and -not $isAdmin) {
    Write-Output "Admin-needed .reg files detected; launching elevated helper..."

    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    $exe = if ($pwshCmd) { $pwshCmd.Source } else { (Get-Command powershell).Source }

    $targetGroups = ($selectedGroups.Keys) -join ','
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Action', $Action, '-Groups', $targetGroups, '-ImportAdminOnly')
    if ($configPath) { $argList += @('-Config', $configPath) }

    try {
        Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -Wait
        foreach ($adm in $adminEntries) {
            $allResults += [PSCustomObject]@{ Group = $adm.Group; File = (Split-Path $adm.Path -Leaf); Success = $true }
        }
    }
    catch {
        Write-Warning "Elevation cancelled or failed: $($_.Exception.Message)"
        foreach ($adm in $adminEntries) {
            $allResults += [PSCustomObject]@{ Group = $adm.Group; File = (Split-Path $adm.Path -Leaf); Success = $false }
        }
    }

    # Now apply non-admin entries
    $nonAdminResults = Apply-RegistryEntries -Entries $nonAdminEntries -Action $Action
    $allResults += $nonAdminResults
}
else {
    # Either elevated already or no admin entries
    $targetAll = $adminEntries + $nonAdminEntries
    $allResults = Apply-RegistryEntries -Entries $targetAll -Action $Action
}

# Display results
if ($allResults.Count -gt 0) {
    $succeeded = $allResults | Where-Object { $_.Success }
    $failed = $allResults | Where-Object { -not $_.Success }

    if ($hasGum -and -not [Console]::IsOutputRedirected) {
        $title = if ($Action -eq 'add') { "Registry Tweaks Applied" } else { "Registry Tweaks Reverted" }
        $borderColor = if ($Action -eq 'add') { "42" } else { "214" }
        $lines = @($title, [string]::new([char]0x2500, [Math]::Max($title.Length, 28)))
        foreach ($s in $succeeded) {
            $lines += "  [+] $($s.Group) ($($s.File))"
        }
        if ($failed.Count -gt 0) {
            $lines += ""
            $lines += "Failed:"
            foreach ($f in $failed) {
                $lines += "  [-] $($f.Group) ($($f.File))"
            }
        }
        $cardContent = $lines -join "`n"
        gum style --border normal --border-foreground $borderColor --padding "0 1" --margin "1 0" $cardContent
    }
    else {
        $color = if ($Action -eq 'add') { 'Green' } else { 'Yellow' }
        foreach ($s in $succeeded) {
            Write-Host "[$($Action.ToUpper())] $($s.Group) ($($s.File))" -ForegroundColor $color
        }
        foreach ($f in $failed) {
            Write-Warning "Failed: $($f.Group) ($($f.File))"
        }
    }
}
