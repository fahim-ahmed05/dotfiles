param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to the configuration JSON file")]
    [string]$ConfigPath
)

# --- 1. Environment & Setup ---
$SetupTempDir = Join-Path $env:TEMP "WinSetup"

# Resolve absolute paths so we know exactly what NOT to delete
$CurrentScriptPath = $MyInvocation.MyCommand.Path
$ConfigFullPath = if (Test-Path $ConfigPath) { (Resolve-Path $ConfigPath).Path } else { $ConfigPath }

# Folder Maintenance
if (Test-Path $SetupTempDir) {
    Write-Host "Cleaning stale setup files..." -ForegroundColor Gray
    # Only delete files that are NOT the script itself or the active config
    Get-ChildItem -Path $SetupTempDir | Where-Object { 
        $_.FullName -ne $CurrentScriptPath -and $_.FullName -ne $ConfigFullPath 
    } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}
else {
    New-Item -Path $SetupTempDir -ItemType Directory -Force | Out-Null
}

# --- 2. Helper Functions ---
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

# --- 3. Configuration Loading ---
if (-not (Test-Path $ConfigPath)) { 
    Write-Error "Configuration file not found at: $ConfigPath"
    exit 
}
$WinSetupConfig = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "--- Initializing System Setup ---" -ForegroundColor Cyan

# --- 4. Core Installations ---
# Execution Policy
if ($null -ne $WinSetupConfig.settings -and $WinSetupConfig.settings.enabled -ne $false -and $null -ne $WinSetupConfig.settings.execution_policy) {
    Write-Host "Setting Execution Policy..."
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $WinSetupConfig.settings.execution_policy -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}

# Pre-Install
if ($null -ne $WinSetupConfig.pre_install_commands) {
    Write-Host "`n--- Running Pre-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.pre_install_commands) {
        if ($cmd.enabled -eq $false) { continue }
        Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
        Invoke-Expression ([System.Environment]::ExpandEnvironmentVariables($cmd.command))
    }
}

# Winget
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

# Scoop
if ($null -ne $WinSetupConfig.scoop -and $WinSetupConfig.scoop.enabled -ne $false) {
    Write-Host "`n--- Checking Scoop ---" -ForegroundColor Cyan
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Invoke-RestMethod -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
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

# uv tools
if ($null -ne $WinSetupConfig.uv -and $WinSetupConfig.uv.enabled -ne $false) {
    Write-Host "`n--- Installing Python Tools via uv ---" -ForegroundColor Cyan
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    uv tool update-shell
    
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        foreach ($tool in $WinSetupConfig.uv.tools) { uv tool install $tool }
    }
}

# --- 5. Batched Post-Install Execution ---
if ($null -ne $WinSetupConfig.post_install_commands) {
    Write-Host "`n--- Preparing Post-Install Tasks ---" -ForegroundColor Cyan
    
    $batch_Normal = @()
    $batch_Pwsh = @()
    $batch_Admin = @()
    $batch_AdminPwsh = @()

    foreach ($cmd in $WinSetupConfig.post_install_commands) {
        if ($cmd.enabled -eq $false) { continue }

        Write-Host "Resolving files for: $($cmd.name)..." -ForegroundColor Gray
        $finalCmd = $cmd.command

        # Expand environment variables FIRST
        $finalCmd = [System.Environment]::ExpandEnvironmentVariables($finalCmd)

        # Resolve remote files
        if ($null -ne $cmd.files) {
            foreach ($fileEntry in $cmd.files) {
                $resolvedPath = Resolve-ExternalPath -Path $fileEntry.path
                if ($null -ne $resolvedPath) {
                    $finalCmd = $finalCmd.Replace($fileEntry.var, $resolvedPath)
                }
            }
        }

        # Wrap the command with progress logging
        $batchedTask = "Write-Host `"  -> Running: $($cmd.name)`" -ForegroundColor Yellow`n$finalCmd`n"

        # Sort into execution buckets
        if ($cmd.admin -eq $true -and $cmd.pwsh -eq $true) {
            $batch_AdminPwsh += $batchedTask
        }
        elseif ($cmd.admin -eq $true) {
            $batch_Admin += $batchedTask
        }
        elseif ($cmd.pwsh -eq $true) {
            $batch_Pwsh += $batchedTask
        }
        else {
            $batch_Normal += $batchedTask
        }
    }

    # Batch Execution Function
    function Run-Batch {
        param([string]$Context, [array]$Commands, [string]$Exe, [bool]$Elevate)
        
        if ($Commands.Count -eq 0) { return }
        
        Write-Host "`n=== Executing Batch: $Context ($($Commands.Count) tasks) ===" -ForegroundColor Cyan
        
        $scriptBlock = $Commands -join "`n"
        
        if ($Elevate) {
            $scriptBlock += "`nWrite-Host `"Batch complete. Closing in 3 seconds...`" -ForegroundColor Green`nStart-Sleep -Seconds 3"
        }

        if ($Exe -eq "current") {
            $sb = [scriptblock]::Create($scriptBlock)
            Invoke-Command -ScriptBlock $sb
        }
        else {
            $encodedCmd = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))
            
            if ($Elevate) {
                Write-Host "Waiting for Administrator Approval..." -ForegroundColor DarkGray
                Start-Process $Exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCmd" -Wait
            }
            else {
                & $Exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCmd
            }
        }
    }

    # Execute all buckets
    Run-Batch -Context "Elevated Tasks (PS 5.1)" -Commands $batch_Admin -Exe "powershell" -Elevate $true
    Run-Batch -Context "Elevated Tasks (PowerShell 7)" -Commands $batch_AdminPwsh -Exe "pwsh" -Elevate $true
    Run-Batch -Context "Standard Tasks (PS 5.1)" -Commands $batch_Normal -Exe "current" -Elevate $false
    Run-Batch -Context "Standard Tasks (PowerShell 7)" -Commands $batch_Pwsh -Exe "pwsh" -Elevate $false
}

Write-Host "`n--- Setup Complete! Please restart your terminal. ---" -ForegroundColor Green