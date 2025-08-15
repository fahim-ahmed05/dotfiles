Write-Host "`n🚀  Setting up Windows..." -ForegroundColor Yellow

# Update winget
Write-Host "`n📦  Updating winget..." -ForegroundColor Cyan
winget update winget --accept-package-agreements --accept-source-agreements

Write-Host "`n📦  Updating winget sources..." -ForegroundColor Cyan
winget source update

# Microsoft Store apps
$msstoreApps = @(
    "9PLJWWSV01LK",     # Twinkle Tray
    # "9nbdxk71nk08",   # WhatsApp Beta
    # "9P4CLT2RJ1RS",   # MusicBee
    # "9pfd136m8457",   # FluentWeather
    # "9pm860492szd",   # Microsoft PC Manager
    # "9nblggh5r558",   # Microsoft To Do
    # "9nctdw2w1bh8",   # Raw Image Extension
    "9n45nsm4tnbp"      # FluentFlyout
)

# Winget packages
$wingetPackages = @(
    "eza-community.eza",                    # eza  
    "junegunn.fzf",                         # fzf
    "ajeetdsouza.zoxide",                   # Zoxide
    "JanDeDobbeleer.OhMyPosh",              # Oh My Posh
    "Microsoft.PowerShell",                 # PowerShell
    "7zip.7zip",                            # 7-Zip
    "AutoHotkey.AutoHotkey",                # AutoHotkey
    # "ente-io.auth-desktop",               # Ente Auth Desktop
    "HermannSchinagl.LinkShellExtension",   # Link Shell Extension
    # "Microsoft.PowerToys",                # PowerToys
    "Notepad++.Notepad++",                  # Notepad++
    # "Proton.ProtonVPN",                   # ProtonVPN
    # "gerardog.gsudo",                     # gsudo
    # "Cloudflare.Warp",                    # Cloudflare WARP
    "voidtools.Everything",                 # Everything
    # "Brave.Brave",                        # Brave Browser
    # "ONLYOFFICE.DesktopEditors",          # ONLYOFFICE Desktop Editors
    "Tonec.InternetDownloadManager",        # Internet Download Manager
    # "CodecGuide.K-LiteCodecPack.Standard",# K-Lite Codec Pack Standard
    "qBittorrent.qBittorrent",              # qBittorrent
    "Fastfetch-cli.Fastfetch",              # Fastfetch
    "Flow-Launcher.Flow-Launcher",          # Flow Launcher
    # "Google.PlatformTools",               # Google Platform Tools
    # "Gyan.FFmpeg",                        # FFmpeg
    # "Microsoft.VisualStudioCode",         # Visual Studio Code
    "SumatraPDF.SumatraPDF",                # SumatraPDF
    "aria2.aria2",                          # aria2
    "Stremio.Stremio",                      # Stremio
    # "KDE.Kdenlive",                       # Kdenlive
    # "PrestonN.FreeTube",                  # FreeTube
    "QL-Win.QuickLook",                     # QuickLook
    # "calibre.calibre",                    # Calibre
    # "Session.Session",                    # Session
    "AdrienAllard.FileConverter",           # File Converter
    # "BlueStack.BlueStacks",               # BlueStacks
    # "PeterPawlowski.foobar2000",          # foobar2000
    # "th-ch.YouTubeMusic"                  # YouTube Music
    "AIMP.AIMP",                            # AIMP
    "eMClient.eMClient"                     # eM Client
)

# Install Microsoft Store apps
Write-Host "`n🎯  Installing Microsoft Store apps..." -ForegroundColor Cyan
foreach ($app in $msstoreApps) {
    winget install $app --source msstore --accept-package-agreements --accept-source-agreements
}

# Install other apps
Write-Host "`n🎯  Installing winget packages..." -ForegroundColor Cyan
foreach ($package in $wingetPackages) {
    winget install $package --source winget --accept-package-agreements --accept-source-agreements
}

# Disable Oh My Posh startup notice
Write-Host "`n⚙️  Disabling Oh My Posh startup notice..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList '-Command', 'oh-my-posh disable notice' -NoNewWindow -Wait
Write-Host "`n✅  Oh My Posh startup notice disabled." -ForegroundColor Green

# Install Scoop and Nerd Fonts
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "`n🎯  Installing Scoop...`n" -ForegroundColor Cyan
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression

    Write-Host "`n📦  Updating scoop...`n" -ForegroundColor Cyan
    scoop update

    # Install Nerd Fonts via Scoop
    Write-Host "`n🔠  Installing Nerd Fonts...`n" -ForegroundColor Cyan
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
    # scoop install nerd-fonts/FiraMono-NF
    scoop install nerd-fonts/UbuntuMono-NF
} else {
    Write-Host "`n❌  Git is not installed. Skipping Scoop and Nerd Fonts installation." -ForegroundColor Yellow
}

# Install Pipx and Python packages
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "`n📦  Installing pipx...`n" -ForegroundColor Cyan
    scoop install pipx
    Start-Process powershell -ArgumentList '-Command', 'pipx ensurepath' -NoNewWindow -Wait

#    $pipxPackages = @("yt-dlp", "spotdl")
#    foreach ($package in $pipxPackages) {
#        pipx install $package
#    }
} else {
    Write-Host "`n❌  Python is not installed. Skipping pipx setup." -ForegroundColor Yellow
}

# Install SpotX
Write-Host "`n🎵  Installing SpotX..." -ForegroundColor Cyan
Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"

# Remove desktop icons
Write-Host "`n🧹  Cleaning desktop icons..." -ForegroundColor Cyan
"$env:USERPROFILE\Desktop", "C:\Users\Public\Desktop" | ForEach-Object {
    Get-ChildItem "$_\*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "`n✅  Desktop icons removed." -ForegroundColor Green

# Done!
Write-Host "`n✅  Windows setup script completed successfully!" -ForegroundColor Green
