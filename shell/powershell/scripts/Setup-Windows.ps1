param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to the configuration JSON file")]
    [string]$ConfigPath
)

if (-not (Test-Path $ConfigPath)) { 
    Write-Error "Configuration file not found at: $ConfigPath"
    exit 
}

# Renamed from $config to $WinSetupConfig to prevent variable collisions with external scripts
$WinSetupConfig = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "--- Initializing System Setup ---" -ForegroundColor Cyan

# 1. Set Execution Policy (Skip if missing, or explicitly disabled)
if ($null -ne $WinSetupConfig.settings -and $WinSetupConfig.settings.enabled -ne $false -and $null -ne $WinSetupConfig.settings.execution_policy) {
    Write-Host "Setting Execution Policy..."
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $WinSetupConfig.settings.execution_policy -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}

# 2. Run Pre-Install Commands (Skip if missing)
if ($null -ne $WinSetupConfig.pre_install_commands) {
    Write-Host "`n--- Running Pre-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.pre_install_commands) {
        # Check if this specific command is disabled
        if ($cmd.enabled -eq $false) {
            Write-Host "Skipping disabled task: $($cmd.name)" -ForegroundColor DarkGray
            continue
        }

        Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
        # Expand %VAR% environment variables before executing
        $expandedCmd = [System.Environment]::ExpandEnvironmentVariables($cmd.command)
        Invoke-Expression $expandedCmd
    }
}

# 3. Handle Winget (Skip if missing or explicitly disabled at the top level)
if ($null -ne $WinSetupConfig.winget -and $WinSetupConfig.winget.enabled -ne $false) {
    Write-Host "`n--- Installing Winget Packages ---" -ForegroundColor Cyan

    # Update Winget sources and packages first
    winget source update 
    winget update winget --accept-package-agreements --accept-source-agreements
    winget update --all --accept-package-agreements --accept-source-agreements

    # Safely fetch Winget arguments if they exist
    $wingetArgs = ""
    if ($null -ne $WinSetupConfig.settings -and $null -ne $WinSetupConfig.settings.winget_args) {
        $wingetArgs = $WinSetupConfig.settings.winget_args
    }

    foreach ($group in $WinSetupConfig.winget) {
        # Check if this specific winget source group is disabled
        if ($group.enabled -eq $false) {
            Write-Host "Skipping disabled Winget group: $($group.source)" -ForegroundColor DarkGray
            continue
        }

        foreach ($pkg in $group.packages) {
            Write-Host "Installing $pkg from $($group.source)..."
            
            # Use Invoke-Expression to prevent PowerShell from quoting the arguments
            $cmd = "winget install $pkg --source $($group.source) $wingetArgs"
            Invoke-Expression $cmd
        }
    }
}

# 4. Handle Scoop (Skip if missing, or explicitly disabled)
if ($null -ne $WinSetupConfig.scoop -and $WinSetupConfig.scoop.enabled -ne $false) {
    Write-Host "`n--- Checking Scoop ---" -ForegroundColor Cyan
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..." -ForegroundColor Yellow
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    # Add Buckets (Skip if array is missing)
    if ($null -ne $WinSetupConfig.scoop.buckets) {
        foreach ($bucket in $WinSetupConfig.scoop.buckets) {
            # Check if this specific bucket is disabled
            if ($bucket.enabled -eq $false) {
                Write-Host "Skipping disabled Scoop bucket: $($bucket.name)" -ForegroundColor DarkGray
                continue
            }

            Write-Host "Adding bucket: $($bucket.name)"
            if ($bucket.url) {
                scoop bucket add $bucket.name $bucket.url
            }
            else {
                scoop bucket add $bucket.name
            }
        }
    }

    # Install Scoop Packages (Skip if array is missing)
    if ($null -ne $WinSetupConfig.scoop.packages) {
        Write-Host "`n--- Installing Scoop Packages ---" -ForegroundColor Cyan

        # Update Scoop and existing apps first
        scoop update
        scoop update -a
        
        foreach ($pkg in $WinSetupConfig.scoop.packages) {
            Write-Host "Installing $pkg..."
            scoop install $pkg
        }
    }
}

# 5. Handle uv tools (Skip if missing, or explicitly disabled)
if ($null -ne $WinSetupConfig.uv -and $WinSetupConfig.uv.enabled -ne $false -and $null -ne $WinSetupConfig.uv.tools) {
    Write-Host "`n--- Installing Python Tools via uv ---" -ForegroundColor Cyan
    
    # Refresh environment variables just in case Scoop just installed uv
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Get-Command uv -ErrorAction SilentlyContinue) {
        foreach ($tool in $WinSetupConfig.uv.tools) {
            Write-Host "Installing $tool..."
            uv tool install $tool
        }
        uv tool update-shell
    }
    else {
        Write-Host "Warning: 'uv' command not found in config or system. Skipping uv tool installations." -ForegroundColor Red
    }
}

# 6. Run Post-Install Commands (Skip if missing)
if ($null -ne $WinSetupConfig.post_install_commands) {
    Write-Host "`n--- Running Post-Install Tasks ---" -ForegroundColor Cyan
    foreach ($cmd in $WinSetupConfig.post_install_commands) {
        # Check if this specific command is disabled
        if ($cmd.enabled -eq $false) {
            Write-Host "Skipping disabled task: $($cmd.name)" -ForegroundColor DarkGray
            continue
        }

        Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
        # Expand %VAR% environment variables before executing
        $expandedCmd = [System.Environment]::ExpandEnvironmentVariables($cmd.command)
        Invoke-Expression $expandedCmd
    }
}

Write-Host "`n--- Setup Complete! Please restart your terminal. ---" -ForegroundColor Green