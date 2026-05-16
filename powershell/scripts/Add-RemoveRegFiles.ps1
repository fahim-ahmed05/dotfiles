Param(
    [string]$Config = (Join-Path $PSScriptRoot "..\configs\reg_files.json"),
    [string[]]$Groups,
    [ValidateSet('add', 'remove')][string]$Action = 'add',
    [switch]$ImportAdminOnly
)

function Expand-PercentVars {
    param([string]$s)
    return [regex]::Replace($s, '%([^%]+)%', { param($m)
            $name = $m.Groups[1].Value
            $envItem = Get-Item -Path ("Env:\" + $name) -ErrorAction SilentlyContinue
            if ($envItem) { return $envItem.Value } else { return $m.Value }
        })
}

# Check elevation
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
# Note: don't warn here unconditionally; warn only if admin-required files are found and elevation fails

# Resolve config path
try {
    $configPath = Resolve-Path -LiteralPath $Config -ErrorAction Stop
}
catch {
    $tryPath = Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -ChildPath $Config
    try {
        $configPath = Resolve-Path -LiteralPath $tryPath -ErrorAction Stop
    }
    catch {
        Write-Error "Config file '$Config' not found. Provide a path or place 'registry-config.json' next to this script."
        exit 1
    }
}

$configDir = Split-Path $configPath -Parent

$jsonText = Get-Content -Raw -Path $configPath
try {
    $json = $jsonText | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse JSON in $($configPath): $($_.Exception.Message)"
    exit 1
}

# Normalize entries: require object mapping group names to arrays or group objects
if ($null -eq $json) { Write-Error "Config is empty"; exit 1 }
if ($json -is [System.Array]) {
    Write-Error "Array config is no longer supported. Use an object mapping group names to arrays."
    exit 1
}

$obj = $json
$selectedGroups = @{}
if (-not $Groups -or $Groups.Count -eq 0) {
    foreach ($prop in $obj.PSObject.Properties) {
        $groupName = $prop.Name
        $groupValue = $prop.Value
        $isEnabled = $true

        if ($groupValue -isnot [System.Array]) {
            if ($groupValue.PSObject.Properties.Name -contains 'enabled' -and $groupValue.enabled -eq $false) {
                $isEnabled = $false
            }
        }

        if ($isEnabled) {
            $selectedGroups[$groupName] = $true
        }
    }
}
else {
    foreach ($groupName in $Groups) {
        $selectedGroups[$groupName] = $true
    }
}

$entries = @()
foreach ($g in $selectedGroups.Keys) {
    if (-not ($obj.PSObject.Properties.Name -contains $g)) { Write-Warning "Group '$g' not found in config."; continue }
    $val = $obj.$g
    if ($val -is [System.Array]) {
        foreach ($p in $val) { $entries += [pscustomobject]@{ Group = $g; Path = $p } }
        continue
    }

    $actionKey = $Action  # 'add' or 'remove'
    if ($val.PSObject.Properties.Name -contains $actionKey) {
        if ($val.$actionKey -is [System.Array]) {
            foreach ($p in $val.$actionKey) { $entries += [pscustomobject]@{ Group = $g; Path = $p } }
        }
        else {
            Write-Warning "Group '$g' $actionKey value is not an array; skipping."
        }
        continue
    }

    Write-Warning "Group '$g' has no '$actionKey' array; skipping."
}

# Resolve and categorize entries into admin-needed vs non-admin
$adminEntries = @()
$nonAdminEntries = @()
foreach ($entry in $entries) {
    $p = $entry.Path
    $group = $entry.Group
    if (-not $p) { Write-Warning "Skipping entry without 'path' value in group $group."; continue }

    $expanded = Expand-PercentVars $p
    if (-not [System.IO.Path]::IsPathRooted($expanded)) { $expanded = Join-Path $configDir $expanded }

    $fileResolved = Resolve-Path -LiteralPath $expanded -ErrorAction SilentlyContinue
    if (-not $fileResolved) { Write-Warning ".reg file not found: $expanded"; continue }
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

# Helper function to apply registry action
function Invoke-RegistryAction {
    param(
        [string]$Path,
        [string]$Action = 'add',
        [string]$Group = ''
    )
    try {
        $proc = Start-Process -FilePath "reg.exe" -ArgumentList @('import', $Path) -NoNewWindow -Wait -PassThru -ErrorAction Stop
        return $proc
    }
    catch {
        Write-Error "Failed to execute registry action on $($Path): $($_.Exception.Message)"
        return $null
    }
}

# Helper function to display and process grouped entries
function Show-GroupedEntries {
    param(
        [pscustomobject[]]$Entries,
        [string]$Action = 'add'
    )
    
    if ($Entries.Count -eq 0) { return }
    
    # Group by group name
    $grouped = @{}
    foreach ($entry in $Entries) {
        if (-not $grouped.ContainsKey($entry.Group)) {
            $grouped[$entry.Group] = @()
        }
        $grouped[$entry.Group] += $entry
    }
    
    # Display each group with color
    $color = if ($Action -eq 'add') { 'Cyan' } else { 'Yellow' }
    foreach ($groupName in ($grouped.Keys | Sort-Object)) {
        Write-Host "$Action : $groupName" -ForegroundColor $color
        foreach ($item in $grouped[$groupName]) {
            $proc = Invoke-RegistryAction -Path $item.Path -Action $Action -Group $item.Group
            if ($proc.ExitCode -ne 0) { Write-Warning "Operation failed for $($item.Path) (exit code $($proc.ExitCode))." }
        }
    }
}


# If called with -ImportAdminOnly, import only admin entries and exit
if ($ImportAdminOnly) {
    Show-GroupedEntries -Entries $adminEntries -Action $Action
    exit 0
}

# If there are admin entries and we're not elevated, launch an elevated helper to import them, then import non-admin here
if ($adminEntries.Count -gt 0 -and -not $isAdmin) {
    Write-Output "Admin-needed .reg files detected; launching elevated helper to import them..."

    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCmd) { $exe = $pwshCmd.Source } else { $exe = (Get-Command powershell).Source }

    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Config', $configPath, '-Action', $Action, '-ImportAdminOnly')
    try {
        Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -Wait
        # After elevated helper finishes, apply action to non-admin entries in this (non-elevated) process
        Show-GroupedEntries -Entries $nonAdminEntries -Action $Action
        exit 0
    }
    catch {
        Write-Warning "Failed to launch elevated helper: $($_.Exception.Message)"
        Write-Warning "Admin-required .reg files detected but elevation failed; skipping admin imports and continuing with non-admin entries."

        # Proceed directly to non-admin entries
        Show-GroupedEntries -Entries $nonAdminEntries -Action $Action

        exit 0
    }
}
# Otherwise (either elevated already or no admin entries): apply action to admin first, then non-admin
$allEntries = $adminEntries + $nonAdminEntries
Show-GroupedEntries -Entries $allEntries -Action $Action
