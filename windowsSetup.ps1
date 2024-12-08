# Generate Powershell Profile
Write-Host "`nGenerating Powershell profile...`n" -ForegroundColor "Cyan"
New-Item -Path $profile -Type File -Force
Write-Host "Done" -ForegroundColor "Green"

# Update Winget Packages
Write-Host "`nUpdating winget packages...`n" -ForegroundColor "Cyan"
winget upgrade --all --accept-package-agreements --accept-source-agreements

# Install Winget Packages
Write-Host "Installing winget packages...`n" -ForegroundColor "Cyan"
winget install Microsoft.PowerShell Brave.Brave.Nightly 7zip.7zip ente-io.auth-desktop Notepad++.Notepad++ Proton.ProtonVPN ONLYOFFICE.DesktopEditors voidtools.Everything AdrienAllard.FileConverter gerardog.gsudo SyncTrayzor.SyncTrayzor GnuPG.Gpg4win Tonec.InternetDownloadManager qBittorrent.qBittorrent QL-Win.QuickLook Bitwarden.Bitwarden Notion.Notion Fastfetch-cli.Fastfetch Flow-Launcher.Flow-Launcher Gyan.FFmpeg JanDeDobbeleer.OhMyPosh Stremio.Stremio SumatraPDF.SumatraPDF KDE.Kdenlive Microsoft.PowerToys HermannSchinagl.LinkShellExtension Schniz.fnm Telegram.TelegramDesktop PrestonN.FreeTube calibre.calibre PDFgear.PDFgear --accept-package-agreements --accept-source-agreements

# Install Scoop Package Manager
Write-Host "`nInstalling scoop...`n" -ForegroundColor "Cyan"
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install Nerd Fonts
Write-Host "`nInstalling nerd fonts...`n" -ForegroundColor "Cyan"
scoop bucket add nerd-fonts
scoop install nerd-fonts/FiraCode-NF nerd-fonts/CascadiaCode-NF nerd-fonts/JetBrainsMono-NF nerd-fonts/Meslo-NF nerd-fonts/SpaceMono-NF nerd-fonts/UbuntuSans-NF

# Update Scoop Packages
Write-Host "`nUpdating scoop packages...`n" -ForegroundColor "Cyan"
scoop update
scoop update --all
scoop status

# Install Pipx
Write-Host "`nInstalling pipx...`n" -ForegroundColor "Cyan"
scoop install pipx
pipx ensurepath

# Install Pipx Packages
Write-Host "`nInstalling pipx packages...`n" -ForegroundColor "Cyan"
pipx install yt-dlp

# Install NodeJS
Write-Host "`nInstalling nodejs...`n" -ForegroundColor "Cyan"
fnm env --use-on-cd | Out-String | Invoke-Expression
fnm use --install-if-missing 20
node -v
npm -v

# Configure Windows Update
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value,
        [string]$Type = "DWord"
    )
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value
}

function Disable-ServiceStartup {
    param (
        [string[]]$Services
    )
    foreach ($service in $Services) {
        Write-Host "Setting $service StartupType to Disabled" -ForegroundColor "Green"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    }
}

Write-Host "`nLimiting Windows update to only security updates..." -ForegroundColor "Cyan"    
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Value 0
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -Value 20
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -Value 365
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays" -Value 4
Write-Host "Done" -ForegroundColor "Green"

Write-Host "`nDisabling automatic Windows update..." -ForegroundColor "Cyan"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0    
Disable-ServiceStartup -Services @("BITS", "wuauserv")
Write-Host "Done" -ForegroundColor "Green"

# Remove desktop Icons
Write-Host "`nRemoving desktop icons..." -ForegroundColor "Cyan"
Remove-ItemSafely $HOME\Desktop\*.lnk, C:\Users\Public\Desktop\*.lnk
Write-Host "Windows setup completed successfully." -ForegroundColor "Green"