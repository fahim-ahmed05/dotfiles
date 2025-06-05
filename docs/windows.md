# Windows

### [Setup Script](https://github.com/fahim-ahmed05/dotfiles/blob/main/ShellScripts/WindowsSetup.ps1)

```powershell
iwr "https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/ShellScripts/WindowsSetup.ps1" | iex
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

#### Update Winget

``` PowerShell
winget upgrade winget
```

or

``` PowerShell
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

#### Winget Packages (Source: Microsoft Store)
ℹ️ _TwinkleTray FluentFlyout UniGetUI FluentWeather_

```PowerShell
winget install 9PLJWWSV01LK 9N45NSM4TNBP XPFFTQ032PTPHF 9PFD136M8457 --source msstore --accept-package-agreements --accept-source-agreements
```

#### Winget Packages (Source: Winget)

``` PowerShell
winget install 7zip.7zip HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Fastfetch-cli.Fastfetch Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF aria2.aria2 Stremio.Stremio QL-Win.QuickLook AdrienAllard.FileConverter PeterPawlowski.foobar2000 th-ch.YouTubeMusic --source winget --accept-package-agreements --accept-source-agreements
```

#### Install [Scoop](https://scoop.sh/)
``` PowerShell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install scoop-search
```

#### Install [Chocolatey](https://chocolatey.org/install)
⚠️ **Administrative shell required**
``` PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Install [Pipx](https://github.com/pypa/pipx)
⚠️ **Python required**
``` PowerShell
scoop install pipx
pipx ensurepath
```
#### Pipx Packages
``` PowerShell
pipx install yt-dlp spotdl
```

### Cursors

| Name | Link |
| :-- | :-- |
| [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor) | [Download](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip) |
| [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/) | |


### Fonts

[Inter](https://rsms.me/inter/download/), [CascadiaCode-NF, JetBrainsMono-NF, UbuntuSans-NF](https://github.com/ryanoasis/nerd-fonts/releases), [SolaimanLipi, AdorshoLipi](https://www.omicronlab.com/bangla-fonts.html), [Ekushey Lal Salu Normal](https://ekushey.org/fonts/)
