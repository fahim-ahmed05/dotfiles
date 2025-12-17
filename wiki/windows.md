# Windows

### [Setup Script](https://github.com/fahim-ahmed05/dotfiles/blob/main/ShellScripts/WindowsSetup.ps1)


```powershell
iwr "https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/powershell/scripts/WindowsSetup.ps1" | iex
```

### Activate Windows ([Massgrave](https://github.com/massgravel/Microsoft-Activation-Scripts))


```powershell
irm "https://get.activated.win" | iex
```

### [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```powershell
irm "https://christitus.com/win" | iex
```

### Programs

| [Revo Uninstaller](https://www.revouninstaller.com/revo-uninstaller-free-download/)  | [Python](https://www.python.org/downloads/) | [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm) | [Git](https://git-scm.com/download/win) | [Visual Studio Code](https://code.visualstudio.com/) | [Traffic Monitor](https://github.com/zhongyang219/TrafficMonitor/releases) | [Winaero Tweaker](https://winaerotweaker.com/) |
|------|------|------|------|------|------|------|

### Update Winget

```powershell
winget upgrade winget
```

or

```powershell
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

### Winget Packages (Source: Microsoft Store)

| [WhatsApp](https://apps.microsoft.com/detail/9nksqgp7f2nh) | [UniGetUI](https://apps.microsoft.com/detail/xpfftq032ptphf) | [Folo](https://apps.microsoft.com/detail/9nvfzpv0v0ht) | [Wintoys](https://apps.microsoft.com/detail/9p8ltpgcbzxd) |
|----------|----------|------|------|

```powershell
winget install 9nksqgp7f2nh xpfftq032ptphf 9nvfzpv0v0ht 9p8ltpgcbzxd --source msstore --accept-package-agreements --accept-source-agreements
```

### Winget Packages (Source: Winget)

```powershell
winget install Microsoft.PowerShell Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension yt-dlp.yt-dlp Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AutoHotkey.AutoHotkey Syncthing.Syncthing Stremio.Stremio Obsidian.Obsidian QL-Win.QuickLook AdrienAllard.FileConverter AIMP.AIMP Brave.Brave eMClient.eMClient Microsoft.PowerToys ente-io.auth-desktop ONLYOFFICE.DesktopEditors Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
```

### Optional Winget Packages (Source: Winget)

```powershell
winget install LocalSend.LocalSend Notion.Notion DuongDieuPhap.ImageGlass Proton.ProtonVPN PeterPawlowski.foobar2000 PrestonN.FreeTube calibre.calibre BlueStack.BlueStacks th-ch.YouTubeMusic --source winget --accept-package-agreements --accept-source-agreements
```

### Install [Scoop](https://scoop.sh/)

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

### Scoop Packages

```powershell
scoop install 7zip aria2 fastfetch nodejs scoop-search
```

### Optional Scoop Packages

```powershell
scoop install phantomjs yamlfmt
```

### Install [Pipx](https://github.com/pypa/pipx)

| [Python](https://www.python.org/downloads/) required |
|------------------------------------------------------|

```powershell
scoop install pipx
pipx ensurepath
```
### Pipx Packages

| [Python](https://www.python.org/downloads/) required |
|------------------------------------------------------|

```powershell
pipx install spotdl
```

### Cursors

| Name |       |
|------|-------|
| [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor) | [Download](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip) |
| [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/) | **N/A** |

### Media Foundation Codecs

| Download                                                              | Install                        |
|-----------------------------------------------------------------------|--------------------------------|
| [Codec Guide](https://www.codecguide.com/media_foundation_codecs.htm) | `Add-AppxPackage *.AppxBundle` |

### Folder Structure

```
~\home
├── persist  -> user managed app files
├── apps     -> portable/user managed apps
├── files    -> files and folders created by user
├── shims    -> symlinks to apps that'll be available in path
├── etc      -> shortcuts to different system folders
└── themes   -> files related to theming
```
