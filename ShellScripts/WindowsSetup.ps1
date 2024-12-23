Write-Host "`nWindows Setup script started..." -ForegroundColor Yellow

# Ensure PowerShell profile exists
if (Test-Path $profile) {
    Write-Host "Profile exists at: $profile" -ForegroundColor Cyan
}
else {
    Write-Host "Profile does not exist. Creating..." -ForegroundColor Yellow
    try {
        New-Item -Path $profile -Type File -Force | Out-Null
        Write-Host "Profile created at: $profile" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create profile at: $profile" -ForegroundColor Red
    }
}

# Install Microsoft Store apps via winget
Write-Host "`nInstalling Microsoft Store applications via winget..." -ForegroundColor Green
$msstoreApps = @(
    "9PLJWWSV01LK", # Twinkle Tray
    "9NKSQGP7F2NH", # WhatsApp
    "9P4CLT2RJ1RS"  # MusicBee
)

foreach ($app in $msstoreApps) {
    try {
        winget install $app --source msstore --accept-package-agreements --accept-source-agreements
        Write-Host "Installed $app successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install $app." -ForegroundColor Red
    }
}

# Install other packages via winget
Write-Host "`nInstalling other applications via winget..." -ForegroundColor Green
$wingetPackages = @(
    "JanDeDobbeleer.OhMyPosh",
    "7zip.7zip",
    "ente-io.auth-desktop",
    "HermannSchinagl.LinkShellExtension",
    "Zen-Team.Zen-Browser.Optimized",
    "Microsoft.PowerToys"
)

foreach ($package in $wingetPackages) {
    try {
        winget install $package --source winget --accept-package-agreements --accept-source-agreements
        Write-Host "Installed $package successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install $package." -ForegroundColor Red
    }
}

Write-Host "`nWinget installations complete!" -ForegroundColor Cyan

# Disable Oh My Posh startup notice
try {
    oh-my-posh disable notice
    Write-Host "Oh My Posh startup notice disabled." -ForegroundColor Green
}
catch {
    Write-Host "Failed to disable Oh My Posh startup notice." -ForegroundColor Red
}

# Install Scoop
Write-Host "`nSetting up Scoop..." -ForegroundColor Green
try {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Host "Scoop installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to install Scoop." -ForegroundColor Red
}

# Install pipx and add to path
Write-Host "`nInstalling pipx and ensuring it's in PATH..." -ForegroundColor Green
try {
    scoop install pipx
    pipx ensurepath
    Write-Host "pipx installed and added to PATH successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to install pipx or add it to PATH." -ForegroundColor Red
}

# Install yt-dlp and spotdl with pipx
Write-Host "`nInstalling packages via pipx..." -ForegroundColor Green
$pipxPackages = @(
    "yt-dlp",
    "spotdl"
)

foreach ($package in $pipxPackages) {
    try {
        pipx install $package
        Write-Host "Installed $package successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install $package." -ForegroundColor Red
    }
}

# Install Nerd Fonts
Write-Host "`nInstalling Nerd Fonts..." -ForegroundColor Green
try {
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
    Write-Host "Nerd Fonts installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to install Nerd Fonts." -ForegroundColor Red
}

Write-Host "`nWindows Setup script completed successfully!" -ForegroundColor Yellow