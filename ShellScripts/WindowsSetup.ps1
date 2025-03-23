$createPowerShellProfile = $true
$installMicrosoftStoreApps = $true
$installOtherPackages = $true
$disableOmpStartupNotice = $true
$setupScoop = $true
$installPipX = $true
$installPipxPackages = $true
$installNerdFonts = $true
$installPsModules = $true
$removeDesktopIcons = $true

Write-Host "Windows Setup script started..." -ForegroundColor Yellow

# Ensure PowerShell profile exists
if ($createPowerShellProfile) {
    $profilePaths = @(
        "$Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1", # Windows PowerShell
        "$Home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",        # PowerShell 7
        "$Home\Documents\PowerShell\Microsoft.VSCode_profile.ps1"             # Visual Studio Code
    )

    foreach ($profilePath in $profilePaths) {
        if (!(Test-Path $profilePath)) {
            New-Item -Path $profilePath -ItemType File -Force
            Write-Host "$profilePath created." -ForegroundColor Green
        }
    }
}

# Install Microsoft Store apps via winget
if ($installMicrosoftStoreApps) {
    Write-Host "Installing Microsoft Store apps..." -ForegroundColor Cyan
    $msstoreApps = @(
        "9PLJWWSV01LK", # Twinkle Tray
        "9nbdxk71nk08", # WhatsApp Beta
        "9P4CLT2RJ1RS", # MusicBee
        "9pfd136m8457", # FluentWeather
        "9pm860492szd", # Microsoft PC Manager
        "9nblggh5r558", # Microsoft To Do
        "9nctdw2w1bh8"  # Raw Image Extension
    )

    foreach ($app in $msstoreApps) {
        winget install $app --source msstore --accept-package-agreements --accept-source-agreements
    }
}

# Install other packages via winget
if ($installOtherPackages) {
    Write-Host "`nInstalling other applications via winget..." -ForegroundColor Cyan
    $wingetPackages = @(
        "JanDeDobbeleer.OhMyPosh",              # Oh My Posh
        "Microsoft.PowerShell",                 # PowerShell
        "7zip.7zip",                            # 7-Zip
        "ente-io.auth-desktop",                 # Ente Auth Desktop
        "HermannSchinagl.LinkShellExtension",   # Link Shell Extension
        "Microsoft.PowerToys",                  # PowerToys
        "Notepad++.Notepad++",                  # Notepad++
        "Proton.ProtonVPN",                     # ProtonVPN
        "gerardog.gsudo",                       # gsudo
        "Cloudflare.Warp",                      # Cloudflare WARP
        "voidtools.Everything",                 # Everything
        #"SyncTrayzor.SyncTrayzor",             # SyncTrayzor
        #"Brave.Brave",                         # Brave Browser
        "ONLYOFFICE.DesktopEditors",            # ONLYOFFICE Desktop Editors
        "Tonec.InternetDownloadManager",        # Internet Download Manager
        #"CodecGuide.K-LiteCodecPack.Standard", # K-Lite Codec Pack Standard
        "qBittorrent.qBittorrent",              # qBittorrent
        "Fastfetch-cli.Fastfetch",              # Fastfetch
        "Flow-Launcher.Flow-Launcher",          # Flow Launcher
        #"Google.PlatformTools",                # Google Platform Tools
        "Gyan.FFmpeg",                          # FFmpeg
        #"Microsoft.VisualStudioCode",          # Visual Studio Code
        "SumatraPDF.SumatraPDF",                # SumatraPDF
        "aria2.aria2",                          # aria2
        "Stremio.Stremio.Beta",                 # Stremio Beta
        #"KDE.Kdenlive",                        # Kdenlive
        #"OpenWhisperSystems.Signal.Beta",      # Signal Beta
        "PrestonN.FreeTube",                    # FreeTube
        "th-ch.YouTubeMusic",                   # YouTube Music
        "QL-Win.QuickLook",                     # QuickLook
        "calibre.calibre",                      # Calibre
        #"Session.Session",                     # Session
        "AdrienAllard.FileConverter",           # File Converter
        #"BlueStack.BlueStacks",                # BlueStacks
        "PeterPawlowski.foobar2000"             # foobar2000
    )

    foreach ($package in $wingetPackages) {
        winget install $package --source winget --accept-package-agreements --accept-source-agreements
    }
}

# Disable Oh My Posh startup notice
if ($disableOmpStartupNotice) {
    oh-my-posh disable notice
    Write-Host "Oh My Posh startup notice disabled." -ForegroundColor Green
}

# Install Scoop
if ($setupScoop) {
    Write-Host "Setting up Scoop..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Install pipx and add to path
if ($installPipX) {
    Write-Host "Installing pipx..." -ForegroundColor Cyan
    scoop install pipx
    pipx ensurepath
}

# Install yt-dlp and spotdl with pipx
if ($installPipxPackages) {
    Write-Host "`nInstalling packages via pipx..." -ForegroundColor Cyan
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
    Write-Host "`nInstalling Nerd Fonts..." -ForegroundColor Cyan
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
    scoop install nerd-fonts/FiraMono-NF
    scoop install nerd-fonts/UbuntuMono-NF
}

# Install Powershell modules
if ($installPsModules) {
    Write-Host "`nInstalling PowerShell modules..." -ForegroundColor Cyan

    gsudo "Install-Module -Name PowerShellGet -Force"                        # PowerShellGet
    gsudo "Install-Module PSReadLine -AllowPrerelease -Force"                # PSReadLine
    gsudo "Install-Module -Name Recycle -RequiredVersion 1.5.0 -Force"       # Recycle
    gsudo "Install-Module -Name Terminal-Icons -Repository PSGallery -Force" # Terminal-Icons
    gsudo "Install-Module -Name z -AllowClobber -Force"                      # z
}

# Remove desktop icons
if($removeDesktopIcons) {
    $desktopPaths = @(
        "$Home\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $desktopPaths) {
        if (Test-Path $path) {
            $lnkFiles = Get-ChildItem -Path $path -Filter "*.lnk" -ErrorAction SilentlyContinue
            if ($lnkFiles) {
                Remove-ItemSafely $lnkFiles.FullName
            }
        }
    }
    Write-Host "Desktop icons have been removed." -ForegroundColor Green
}

Write-Host "Windows Setup script completed successfully!" -ForegroundColor Green