param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to the configuration JSON file")]
    [string]$ConfigPath
)

# 1. Unified directory for both Bootstrap and direct Script execution
$SetupTempDir = Join-Path $env:TEMP "WinSetup"

# 2. Folder Maintenance: Ensure a clean environment for repo updates
if (Test-Path $SetupTempDir) {
    if ((Get-ChildItem -Path $SetupTempDir).Count -gt 0) {
        Write-Host "Cleaning existing setup files..." -ForegroundColor Gray
        Remove-Item -Path "$SetupTempDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
} else {
    New-Item -Path $SetupTempDir -ItemType Directory -Force | Out-Null
}

# 3. Helper Function: Resolve GitHub/Remote Paths
function Resolve-ExternalPath {
    param([string]$Path)
    
    if ($Path -like "http*") {
        # Create a unique ID to prevent collisions between same-named files
        $urlHash = [BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Path))).Replace("-", "").Substring(0, 8)
        $fileName = Split-Path $Path -Leaf
        $localPath = Join-Path $SetupTempDir "$urlHash`_$fileName"
        
        # Don't re-download if it already exists in this session
        if (Test-Path $localPath) { return $localPath }

        Write-Host "  -> Downloading: $fileName" -ForegroundColor Gray
        try {
            # Bypass cache to ensure GitHub Raw updates are immediate
            Invoke-WebRequest -Uri $Path -OutFile $localPath -ErrorAction Stop -Headers @{"Cache-Control"="no-cache"}
            return $localPath
        } catch {
            Write-Error "Failed to download $Path"
            return $null
        }
    }
    return [System.Environment]::ExpandEnvironmentVariables($Path)
}

if (-not (Test-Path $ConfigPath)) { 
    Write-Error "Configuration file not found at: $ConfigPath"
    exit 
}

$WinSetupConfig = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "--- Initializing System Setup ---" -ForegroundColor Cyan

# 1. Set Execution Policy
if ($null -ne $WinSetupConfig.settings -and $WinSetupConfig.settings.enabled -ne $false -and $null -ne $WinSetupConfig.settings.execution_policy) {
    Write-Host "Setting Execution Policy..."
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $WinSetupConfig.settings.execution_policy -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}

# 2. Run Pre-Install Commands
if ($null -ne $WinSetupConfig.pre_install_commands) {
    Write-Host "`n--- Running Pre-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.pre_install_commands) {
        if ($cmd.enabled -eq $false) { continue }
        Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
        Invoke-Expression ([System.Environment]::ExpandEnvironmentVariables($cmd.command))
    }
}

# 3. Handle Winget
if ($null -ne $WinSetupConfig.winget -and $WinSetupConfig.winget.enabled -ne $false) {
    Write-Host "`n--- Installing Winget Packages ---" -ForegroundColor Cyan
    winget source update 
    $wingetArgs = if ($WinSetupConfig.settings.winget_args) { $WinSetupConfig.settings.winget_args } else { "" }

    foreach ($group in $WinSetupConfig.winget) {
        if ($group.enabled -eq $false) { continue }
        foreach ($pkg in $group.packages) {
            Write-Host "Installing $pkg from $($group.source)..."
            Invoke-Expression "winget install $pkg --source $($group.source) $wingetArgs"
        }
    }
}

# 4. Handle Scoop
if ($null -ne $WinSetupConfig.scoop -and $WinSetupConfig.scoop.enabled -ne $false) {
    Write-Host "`n--- Checking Scoop ---" -ForegroundColor Cyan
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    if ($null -ne $WinSetupConfig.scoop.buckets) {
        foreach ($bucket in $WinSetupConfig.scoop.buckets) {
            if ($bucket.enabled -eq $false) { continue }
            if ($bucket.url) { scoop bucket add $bucket.name $bucket.url } else { scoop bucket add $bucket.name }
        }
    }
    if ($null -ne $WinSetupConfig.scoop.packages) {
        scoop update; scoop update -a
        foreach ($pkg in $WinSetupConfig.scoop.packages) { scoop install $pkg }
    }
}

# 5. Handle uv tools
if ($null -ne $WinSetupConfig.uv -and $WinSetupConfig.uv.enabled -ne $false) {
    Write-Host "`n--- Installing Python Tools via uv ---" -ForegroundColor Cyan
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        foreach ($tool in $WinSetupConfig.uv.tools) { uv tool install $tool }
    }
}

# 6. Run Post-Install Commands (With Dynamic File Resolution)
if ($null -ne $WinSetupConfig.post_install_commands) {
    Write-Host "`n--- Running Post-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.post_install_commands) {
        if ($cmd.enabled -eq $false) { continue }

        Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
        $finalCmd = $cmd.command

        # Resolve remote files from the 'files' array
        if ($null -ne $cmd.files) {
            foreach ($fileEntry in $cmd.files) {
                $resolvedPath = Resolve-ExternalPath -Path $fileEntry.path
                if ($null -ne $resolvedPath) {
                    # Swaps {{placeholder}} with the actual local temp path
                    $finalCmd = $finalCmd.Replace($fileEntry.var, $resolvedPath)
                }
            }
        } else {
            $finalCmd = [System.Environment]::ExpandEnvironmentVariables($finalCmd)
        }

        Invoke-Expression $finalCmd
    }
}

Write-Host "`n--- Setup Complete! Please restart your terminal. ---" -ForegroundColor Green