# Windows

### [Setup Script](https://github.com/fahim-ahmed05/dotfiles/blob/main/ShellScripts/WindowsSetup.ps1)

```powershell
iwr "https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/powershell/scripts/WindowsSetup.ps1" | iex
```

### Activate Windows ([Massgrave](https://github.com/massgravel/Microsoft-Activation-Scripts))

```powershell
irm https://get.activated.win | iex
```

### Programs

- [Revo Uninstaller](https://www.revouninstaller.com/revo-uninstaller-free-download/) 
- [Python](https://www.python.org/downloads/)
- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Traffic Monitor](https://github.com/zhongyang219/TrafficMonitor/releases)
- [Winaero Tweaker](https://winaerotweaker.com/)

### Update Winget

```powershell
winget upgrade winget
```

or

```powershell
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

### Winget Packages (Source: Microsoft Store)
ℹ️ _WhatsApp TwinkleTray FluentFlyout UniGetUI FluentWeather_

```powershell
winget install 9NKSQGP7F2NH 9PLJWWSV01LK 9N45NSM4TNBP XPFFTQ032PTPHF 9PFD136M8457 --source msstore --accept-package-agreements --accept-source-agreements
```

### Winget Packages (Source: Winget)

```powershell
winget install 7zip.7zip HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Fastfetch-cli.Fastfetch Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF aria2.aria2 Stremio.Stremio QL-Win.QuickLook AdrienAllard.FileConverter PeterPawlowski.foobar2000 th-ch.YouTubeMusic Gyan.FFmpeg eMClient.eMClient Microsoft.PowerToys ente-io.auth-desktop Proton.ProtonVPN ONLYOFFICE.DesktopEditors PrestonN.FreeTube calibre.calibre Cloudflare.Warp Tonec.InternetDownloadManager BlueStack.BlueStacks --source winget --accept-package-agreements --accept-source-agreements
```

### Install [Scoop](https://scoop.sh/)
```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install scoop-search
```

### Install [Chocolatey](https://chocolatey.org/install)
⚠️ **Administrative shell required**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Install [Pipx](https://github.com/pypa/pipx)
⚠️ **Python required**
```powershell
scoop install pipx
pipx ensurepath
```
### Pipx Packages
⚠️ **Python required**
```powershell
pipx install yt-dlp spotdl
```
### Insall [SpotX](https://github.com/SpotX-Official/SpotX)
```powershell
Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"
```

### Cursors

| Name | Download |
| :-- | :--: |
| [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor) | [⬇️](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip) |
| [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/) | ⛓️‍💥 |

---

[Browser](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/browser.md) | [Network](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/network.md) | [PowerShell](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/powershell.md) 