param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the configuration JSON file")]
    [string]$ConfigPath
)

if (-not (Test-Path $ConfigPath)) { 
    Write-Error "Configuration file not found at: $ConfigPath"
    exit 
}

$config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "--- Initializing System Setup ---" -ForegroundColor Cyan

# 1. Set Execution Policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $config.settings.execution_policy -Force

# 2. Handle Network Settings (DNS & NTP)
Write-Host "`n--- Configuring Network Settings ---" -ForegroundColor Cyan

# NTP Server
if ($config.network.ntp_server) {
    # Windows likes the 0x9 flag (client mode) appended to NTP servers
    $ntpTarget = "$($config.network.ntp_server),0x9"
    Write-Host "Setting NTP Server to: $ntpTarget"
    Set-Service -Name w32time -StartupType Automatic
    Start-Service w32time -ErrorAction SilentlyContinue
    w32tm /config /syncfromflags:manual /manualpeerlist:"$ntpTarget" /update | Out-Null
    Restart-Service w32time
    w32tm /resync | Out-Null
}

# DNS and DoH
if ($config.network.dns) {
    # Add DoH Templates to Windows
    Write-Host "Registering DoH Templates..."
    if ($config.network.doh_template) {
        foreach ($ip in $config.network.dns) {
            $cmd = "netsh dns add encryption server=$ip dohtemplate=$($config.network.doh_template) autoupgrade=yes udpfallback=no"
            Invoke-Expression $cmd 2>$null # Suppress errors if the template already exists
        }
    }

    # Apply DNS to all currently active network adapters
    $ActiveAdapters = Get-NetAdapter | Where-Object Status -eq 'Up'
    foreach ($Adapter in $ActiveAdapters) {
        Write-Host "Applying custom DNS to adapter: $($Adapter.Name)..."
        Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses $config.network.dns
    }
}

# 3. Run Pre-Install Commands
Write-Host "`n--- Running Pre-Install Tasks ---" -ForegroundColor Cyan
foreach ($cmd in $config.pre_install_commands) {
    Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
    Invoke-Expression $cmd.command
}

# 4. Handle Winget
Write-Host "`n--- Installing Winget Packages ---" -ForegroundColor Cyan
foreach ($group in $config.winget) {
    foreach ($pkg in $group.packages) {
        Write-Host "Installing $pkg from $($group.source)..."
        winget install $pkg --source $($group.source) $config.settings.winget_args
    }
}

# 5. Handle Scoop
Write-Host "`n--- Checking Scoop ---" -ForegroundColor Cyan
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop..." -ForegroundColor Yellow
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Add Buckets
foreach ($bucket in $config.scoop.buckets) {
    Write-Host "Adding bucket: $($bucket.name)"
    if ($bucket.url) {
        scoop bucket add $bucket.name $bucket.url
    } else {
        scoop bucket add $bucket.name
    }
}

# Install Scoop Packages
Write-Host "Installing Scoop packages..."
scoop install ($config.scoop.packages -join " ")

# 6. Handle uv tools
Write-Host "`n--- Installing Python Tools via uv ---" -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

if (Get-Command uv -ErrorAction SilentlyContinue) {
    foreach ($tool in $config.uv.tools) {
        Write-Host "Installing $tool..."
        uv tool install $tool
    }
} else {
    Write-Host "Warning: 'uv' command not found. Skipping uv tool installations." -ForegroundColor Red
}

# 7. Run Post-Install Commands
Write-Host "`n--- Running Post-Install Tasks ---" -ForegroundColor Cyan
foreach ($cmd in $config.post_install_commands) {
    Write-Host "Running: $($cmd.name)" -ForegroundColor Yellow
    Invoke-Expression $cmd.command
}

Write-Host "`n--- Setup Complete! Please restart your terminal. ---" -ForegroundColor Green