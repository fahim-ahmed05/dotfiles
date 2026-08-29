param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to the configuration JSON file")]
    [string]$ConfigPath
)

# --- 1. Environment & Setup ---
$SetupTempDir = Join-Path $env:TEMP "WinSetup"
$CurrentScriptPath = $MyInvocation.MyCommand.Path
$ConfigFullPath = if (Test-Path $ConfigPath) { (Resolve-Path $ConfigPath).Path } else { $ConfigPath }

if (Test-Path $SetupTempDir) {
    Write-Host "Cleaning stale setup files..." -ForegroundColor Gray
    Get-ChildItem -Path $SetupTempDir | Where-Object { 
        $_.FullName -ne $CurrentScriptPath -and $_.FullName -ne $ConfigFullPath 
    } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
else {
    New-Item -Path $SetupTempDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $ConfigPath)) { 
    Write-Error "Configuration file not found at: $ConfigPath"
    exit 
}
$WinSetupConfig = Get-Content $ConfigPath | ConvertFrom-Json

# --- 2. Global State Evaluation ---
$global:ScoopAllowed = $false
if ($null -ne $WinSetupConfig.scoop -and $WinSetupConfig.scoop.enabled -ne $false) {
    $hasPackages = ($null -ne $WinSetupConfig.scoop.packages -and $WinSetupConfig.scoop.packages.Count -gt 0)
    $hasBuckets = ($null -ne $WinSetupConfig.scoop.buckets -and $WinSetupConfig.scoop.buckets.Count -gt 0)
    if ($hasPackages -or $hasBuckets) {
        $global:ScoopAllowed = $true
    }
}

# --- 3. Helper Functions ---
function Update-EnvironmentPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Resolve-ExternalPath {
    param([string]$Path)
    
    if ($Path -like "http*") {
        $urlHash = [BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Path))).Replace("-", "").Substring(0, 8)
        $fileName = Split-Path $Path -Leaf
        $localPath = Join-Path $SetupTempDir "$urlHash`_$fileName"
        
        if (Test-Path $localPath) { return $localPath }

        Write-Host "  -> Downloading: $fileName" -ForegroundColor Gray
        try {
            Invoke-WebRequest -Uri $Path -OutFile $localPath -ErrorAction Stop -Headers @{"Cache-Control" = "no-cache" } -UseBasicParsing
            return $localPath
        }
        catch {
            Write-Error "Failed to download $Path"
            return $null
        }
    }
    return [System.Environment]::ExpandEnvironmentVariables($Path)
}

function Install-Dependency {
    param([string]$Name)
    
    Update-EnvironmentPath
    if (Get-Command $Name -ErrorAction SilentlyContinue) { return }

    Write-Host "  -> Dynamically resolving missing dependency: $Name..." -ForegroundColor Magenta

    # Winget Fallback Map
    $wingetMap = @{
        "pwsh" = "Microsoft.PowerShell"
        "git"  = "Git.Git"
        "uv"   = "astral-sh.uv"
        "mise" = "jdx.mise"
    }

    if ($Name -eq "scoop") {
        if (-not $global:ScoopAllowed) { return }
        Write-Host "  -> Bootstrapping Scoop..." -ForegroundColor DarkGray
        Invoke-RestMethod -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
        Update-EnvironmentPath
        return
    }

    if ($global:ScoopAllowed) {
        Install-Dependency "scoop"
        Write-Host "  -> Installing $Name via Scoop..." -ForegroundColor DarkGray
        & scoop install $Name
    }
    else {
        $wingetId = $wingetMap[$Name]
        if ($wingetId) {
            Write-Host "  -> Installing $Name via Winget (Scoop bypassed)..." -ForegroundColor DarkGray
            & winget install --id $wingetId --accept-package-agreements --accept-source-agreements --exact --silent
        } else {
            Write-Warning "No fallback mapping found for dependency: $Name"
        }
    }
    
    Update-EnvironmentPath
}

function Invoke-SetupTask {
    param($cmd)
    
    if ($cmd.enabled -eq $false) { return }

    Write-Host "`nTask: $($cmd.name)" -ForegroundColor Yellow
    $finalCmd = $cmd.command
    $finalCmd = [System.Environment]::ExpandEnvironmentVariables($finalCmd)

    # Handle File Substitutions
    if ($null -ne $cmd.files) {
        foreach ($fileEntry in $cmd.files) {
            $resolvedPath = Resolve-ExternalPath -Path $fileEntry.path
            if ($null -ne $resolvedPath) {
                $finalCmd = $finalCmd.Replace($fileEntry.var, $resolvedPath)
            } else {
                Write-Warning "Failed to resolve path for $($fileEntry.var). Skipping substitution."
            }
        }
    }

    # Dynamic Dependency Resolution
    if ($cmd.pwsh -eq $true) { Install-Dependency "pwsh" }

    $encodedCmd = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($finalCmd))

    # Execution Logistics
    if ($cmd.admin -eq $true) {
        $exe = if ($cmd.pwsh -eq $true) { "pwsh" } else { "powershell" }
        Write-Host "  -> Requesting Administrator Privileges ($exe)..." -ForegroundColor DarkGray
        Start-Process -FilePath $exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCmd" -Wait
    }
    elseif ($cmd.pwsh -eq $true) {
        Write-Host "  -> Executing via PowerShell 7 (pwsh)..." -ForegroundColor DarkGray
        & pwsh -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCmd
    }
    else {
        Invoke-Expression $finalCmd
    }
}

Write-Host "--- Initializing System Setup ---" -ForegroundColor Cyan

# --- 4. Core Settings ---
if ($null -ne $WinSetupConfig.settings -and $WinSetupConfig.settings.enabled -ne $false -and $null -ne $WinSetupConfig.settings.execution_policy) {
    Write-Host "Setting Execution Policy..."
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $WinSetupConfig.settings.execution_policy -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}

# --- 5. Pre-Install Tasks ---
if ($null -ne $WinSetupConfig.pre_install_commands) {
    Write-Host "`n--- Running Pre-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.pre_install_commands) { Invoke-SetupTask -cmd $cmd }
}

# --- 6. Winget Phase ---
Write-Host "`n--- Upgrading Winget ---" -ForegroundColor Cyan
& winget upgrade winget --accept-package-agreements --accept-source-agreements

if ($null -ne $WinSetupConfig.winget) {
    Write-Host "`n--- Installing Winget Packages ---" -ForegroundColor Cyan
    & winget update source
    $wingetArgs = if ($WinSetupConfig.settings.winget_args) { $WinSetupConfig.settings.winget_args } else { "" }
    $argsList = $wingetArgs -split ' ' | Where-Object { $_ -ne '' }

    foreach ($group in $WinSetupConfig.winget) {
        if ($group.enabled -eq $false) { continue }
        foreach ($pkg in $group.packages) {
            Write-Host "Installing $pkg from $($group.source)..."
            $cmdArgs = @("install", "--id", $pkg, "--source", $group.source) + $argsList
            & winget @cmdArgs
        }
    }
}

# --- 7. Scoop Phase ---
if ($global:ScoopAllowed) {
    Write-Host "`n--- Installing Scoop & Packages ---" -ForegroundColor Cyan
    Install-Dependency "scoop"

    if ($null -ne $WinSetupConfig.scoop.buckets -and $WinSetupConfig.scoop.buckets.Count -gt 0) { 
        Install-Dependency "git" 
        foreach ($bucket in $WinSetupConfig.scoop.buckets) {
            if ($bucket.enabled -eq $false) { continue }
            if ($bucket.url) { & scoop bucket add $bucket.name $bucket.url } else { & scoop bucket add $bucket.name }
        }
    }
    
    if ($null -ne $WinSetupConfig.scoop.packages -and $WinSetupConfig.scoop.packages.Count -gt 0) {
        & scoop update; & scoop update -a
        foreach ($pkg in $WinSetupConfig.scoop.packages) { & scoop install $pkg }
    }
}

# --- 8. uv Phase ---
if ($null -ne $WinSetupConfig.uv -and $WinSetupConfig.uv.enabled -ne $false -and $null -ne $WinSetupConfig.uv.tools -and $WinSetupConfig.uv.tools.Count -gt 0) {
    Write-Host "`n--- Installing Python Tools via uv ---" -ForegroundColor Cyan
    Install-Dependency "uv"
    
    Update-EnvironmentPath
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        & uv tool update-shell
        foreach ($tool in $WinSetupConfig.uv.tools) { & uv tool install $tool }
    }
}

# --- 9. mise Phase ---
if ($null -ne $WinSetupConfig.mise -and $WinSetupConfig.mise.enabled -ne $false -and $null -ne $WinSetupConfig.mise.tools -and $WinSetupConfig.mise.tools.Count -gt 0) {
    Write-Host "`n--- Configuring Tools via mise ---" -ForegroundColor Cyan
    Install-Dependency "mise"
    
    Update-EnvironmentPath
    if (Get-Command mise -ErrorAction SilentlyContinue) {
        foreach ($tool in $WinSetupConfig.mise.tools) { 
            Write-Host "  -> Setting up $tool via mise..." -ForegroundColor Gray
            & mise use -g $tool
        }
    }
}

# --- 10. Post-Install Phase ---
if ($null -ne $WinSetupConfig.post_install_commands) {
    Write-Host "`n--- Running Post-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.post_install_commands) { Invoke-SetupTask -cmd $cmd }
}

Write-Host "`n--- Setup Complete! Please restart your terminal. ---" -ForegroundColor Green