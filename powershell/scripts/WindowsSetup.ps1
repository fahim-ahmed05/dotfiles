$installMicrosoftStoreApps = $true
$installOtherPackages = $true
$disableOmpStartupNotice = $true
$setupScoop = $true
$setupPipX = $true
$installPipxPackages = $true
$installNerdFonts = $true
$removeDesktopIcons = $true

Write-Host "Windows Setup script started..." -ForegroundColor Yellow

# update winget
write-host "Updating winget..." -ForegroundColor Cyan
if (Get-Command winget -ErrorAction SilentlyContinue) {
    try {
        winget --version
        Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
        winget source update
    }
    catch {
        Write-Host "❌ Winget upgrade failed." -ForegroundColor Red
    }
}
else {
    Write-Host "⚠️ Winget not installed." -ForegroundColor Yellow
}
winget --version

# Install Microsoft Store apps via winget
if ($installMicrosoftStoreApps) {
    Write-Host "Installing Microsoft Store apps via winget..." -ForegroundColor Cyan
    $msstoreApps = @(
        "9PLJWWSV01LK",     # Twinkle Tray
#       "9nbdxk71nk08",     # WhatsApp Beta
#       "9P4CLT2RJ1RS",     # MusicBee
#       "9pfd136m8457",     # FluentWeather
#       "9pm860492szd",     # Microsoft PC Manager
#       "9nblggh5r558",     # Microsoft To Do
#       "9nctdw2w1bh8",     # Raw Image Extension
        "9n45nsm4tnbp"      # FluentFlyout
    )

    foreach ($app in $msstoreApps) {
        winget install $app --source msstore --accept-package-agreements --accept-source-agreements
    }
}

# Install apps via winget
if ($installOtherPackages) {
    Write-Host "Installing apps via winget..." -ForegroundColor Cyan
    $wingetPackages = @(
        "eza-community.eza",                    # eza  
        "junegunn.fzf",                         # fzf
        "ajeetdsouza.zoxide",                   # Zoxide
        "JanDeDobbeleer.OhMyPosh",              # Oh My Posh
        "Microsoft.PowerShell",                 # PowerShell
        "7zip.7zip",                            # 7-Zip
#       "ente-io.auth-desktop",                 # Ente Auth Desktop
        "HermannSchinagl.LinkShellExtension",   # Link Shell Extension
#       "Microsoft.PowerToys",                  # PowerToys
        "Notepad++.Notepad++",                  # Notepad++
#       "Proton.ProtonVPN",                     # ProtonVPN
#       "gerardog.gsudo",                       # gsudo
#       "Cloudflare.Warp",                      # Cloudflare WARP
        "voidtools.Everything",                 # Everything
#       "Brave.Brave",                          # Brave Browser
#       "ONLYOFFICE.DesktopEditors",            # ONLYOFFICE Desktop Editors
        "Tonec.InternetDownloadManager",        # Internet Download Manager
#       "CodecGuide.K-LiteCodecPack.Standard",  # K-Lite Codec Pack Standard
        "qBittorrent.qBittorrent",              # qBittorrent
        "Fastfetch-cli.Fastfetch",              # Fastfetch
        "Flow-Launcher.Flow-Launcher",          # Flow Launcher
#       "Google.PlatformTools",                 # Google Platform Tools
#       "Gyan.FFmpeg",                          # FFmpeg
#       "Microsoft.VisualStudioCode",           # Visual Studio Code
        "SumatraPDF.SumatraPDF",                # SumatraPDF
        "aria2.aria2",                          # aria2
        "Stremio.Stremio",                      # Stremio
#       "KDE.Kdenlive",                         # Kdenlive
#       "PrestonN.FreeTube",                    # FreeTube
        "QL-Win.QuickLook",                     # QuickLook
#       "calibre.calibre",                      # Calibre
#       "Session.Session",                      # Session
        "AdrienAllard.FileConverter",           # File Converter
#       "BlueStack.BlueStacks",                 # BlueStacks
        "PeterPawlowski.foobar2000"             # foobar2000
        "th-ch.YouTubeMusic"                    # YouTube Music
    )

    foreach ($package in $wingetPackages) {
        winget install $package --source winget --accept-package-agreements --accept-source-agreements
    }
}

# Disable Oh My Posh startup notice
if ($disableOmpStartupNotice) {
    wt --profile $env:WT_PROFILE_ID oh-my-posh disable notice
    Write-Host "Oh My Posh startup notice disabled." -ForegroundColor Green
}

# Install Scoop
if ($setupScoop) {
    Write-Host "Setting up Scoop..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Install pipx and add to path
if ($setupPipX) {
    Write-Host "Setting up pipx..." -ForegroundColor Cyan
    scoop install pipx
    wt --profile $env:WT_PROFILE_ID pipx ensurepath
}

# Install yt-dlp and spotdl with pipx
if ($installPipxPackages) {
    Write-Host "Installing python packages via pipx..." -ForegroundColor Cyan
    $pipxPackages = @(
        "yt-dlp",
        "spotdl"
    )

    foreach ($package in $pipxPackages) {
        pipx install $package
    }
}

# Install Nerd Fonts
if ($installNerdFonts) {
    Write-Host "Installing Nerd Fonts via scoop..." -ForegroundColor Cyan
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
#   scoop install nerd-fonts/FiraMono-NF
    scoop install nerd-fonts/UbuntuMono-NF
}

# Remove desktop icons
if ($removeDesktopIcons) {
    $desktopLinks = @(
        "$Home\Desktop\*.lnk",
        "C:\Users\Public\Desktop\*.lnk"
    )

    foreach ($path in $desktopLinks) {
        try {
            Remove-Item -Path $path -Force -ErrorAction Stop
            Write-Host "Removed: $path" -ForegroundColor Green
        }
        catch {
            Write-Host "Could not remove: $path (`$($_.Exception.Message)`)" -ForegroundColor Yellow
        }
    }
}

Write-Host "Windows Setup script completed successfully!" -ForegroundColor Green