# Install packages via winget
Write-Host "Installing applications via winget..." -ForegroundColor Green

# Twinkle Tray, WhatsApp, MusicBee
winget install 9PLJWWSV01LK 9NKSQGP7F2NH 9P4CLT2RJ1RS --source msstore --accept-package-agreements --accept-source-agreements

winget install 7zip.7zip ente-io.auth-desktop HermannSchinagl.LinkShellExtension Notepad++.Notepad++ ONLYOFFICE.DesktopEditors Proton.ProtonVPN Cloudflare.Warp voidtools.Everything gerardog.gsudo Brave.Brave Tonec.InternetDownloadManager PrestonN.FreeTube Fastfetch-cli.Fastfetch Flow-Launcher.Flow-Launcher Gyan.FFmpeg Stremio.Stremio SumatraPDF.SumatraPDF Microsoft.PowerToys QL-Win.QuickLook AdrienAllard.FileConverter SyncTrayzor.SyncTrayzor qBittorrent.qBittorrent.Qt6 --source winget --accept-package-agreements --accept-source-agreements

# Install Scoop
Write-Host "Setting up Scoop..." -ForegroundColor Green
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install pipx and add to path
Write-Host "Installing pipx and ensuring it's in PATH..." -ForegroundColor Green
scoop install pipx
pipx ensurepath

# Install yt-dlp and spotdl with pipx
Write-Host "Installing yt-dlp and spotdl via pipx..." -ForegroundColor Green
pipx install yt-dlp
pipx install spotdl

