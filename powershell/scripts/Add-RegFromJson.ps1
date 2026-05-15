Param(
    [string]$Config = "registry-config.json",
    [string[]]$Groups,
    [switch]$Elevated,
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
if (-not $isAdmin) {
    Write-Warning "Process is not elevated; importing .reg may fail without admin rights."
}

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
    Write-Error "Failed to parse JSON in $configPath: $_"
    exit 1
}

# Normalize entries: require object mapping group names to arrays
if ($null -eq $json) { Write-Error "Config is empty"; exit 1 }
if ($json -is [System.Array]) {
    Write-Error "Array config is no longer supported. Use an object mapping group names to arrays."
    exit 1
}

$obj = $json
if (-not $Groups -or $Groups.Count -eq 0) {
    $groupNames = $obj.PSObject.Properties | ForEach-Object { $_.Name }
}
else {
    $groupNames = $Groups
}

$entries = @()
foreach ($g in $groupNames) {
    if (-not ($obj.PSObject.Properties.Name -contains $g)) { Write-Warning "Group '$g' not found in config."; continue }
    $val = $obj.$g
    if (-not ($val -is [System.Array])) { Write-Warning "Group '$g' is not an array; skipping."; continue }
    $entries += $val
}

# Resolve and categorize entries into admin-needed vs non-admin
$adminEntries = @()
$nonAdminEntries = @()
foreach ($entry in $entries) {
    $p = $null
    if ($entry -is [string]) { $p = $entry } else {
        if ($entry.path) { $p = $entry.path } elseif ($entry.Path) { $p = $entry.Path }
    }
    if (-not $p) { Write-Warning "Skipping entry without 'path' value."; continue }

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

    if ($isAdminFile) { $adminEntries += [pscustomobject]@{ Path = $fullPath; Content = $content } }
    else { $nonAdminEntries += [pscustomobject]@{ Path = $fullPath; Content = $content } }
}

# If called with -ImportAdminOnly, import only admin entries and exit
if ($ImportAdminOnly) {
    foreach ($item in $adminEntries) {
        Write-Output "(elevated) Importing admin registry file: $($item.Path)"
        $proc = Start-Process -FilePath "reg.exe" -ArgumentList @('import', $item.Path) -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -ne 0) { Write-Warning "Import failed for $($item.Path) (exit code $($proc.ExitCode))." }
    }
    exit 0
}

# If there are admin entries and we're not elevated, launch an elevated helper to import them, then import non-admin here
if ($adminEntries.Count -gt 0 -and -not $isAdmin) {
    Write-Output "Admin-needed .reg files detected; launching elevated helper to import them..."

    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCmd) { $exe = $pwshCmd.Source } else { $exe = (Get-Command powershell).Source }

    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-Config', $configPath, '-ImportAdminOnly')
    Start-Process -FilePath $exe -ArgumentList $argList -Verb RunAs -Wait

    # After elevated helper finishes, import non-admin entries in this (non-elevated) process
    foreach ($item in $nonAdminEntries) {
        Write-Output "Importing non-admin registry file: $($item.Path)"
        $proc = Start-Process -FilePath "reg.exe" -ArgumentList @('import', $item.Path) -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -ne 0) { Write-Warning "Import failed for $($item.Path) (exit code $($proc.ExitCode))." }
    }

    exit 0
}

# Otherwise (either elevated already or no admin entries): import admin first, then non-admin
foreach ($item in $adminEntries) {
    Write-Output "Importing admin registry file: $($item.Path)"
    $proc = Start-Process -FilePath "reg.exe" -ArgumentList @('import', $item.Path) -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { Write-Warning "Import failed for $($item.Path) (exit code $($proc.ExitCode))." }
}

foreach ($item in $nonAdminEntries) {
    Write-Output "Importing non-admin registry file: $($item.Path)"
    $proc = Start-Process -FilePath "reg.exe" -ArgumentList @('import', $item.Path) -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { Write-Warning "Import failed for $($item.Path) (exit code $($proc.ExitCode))." }
}
