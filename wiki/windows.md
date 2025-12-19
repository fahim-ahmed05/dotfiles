# Windows

## Change Powershell Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Install [Scoop](https://scoop.sh/)

> [!IMPORTANT]
> Git is required!

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

## Programs

- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Code](https://code.visualstudio.com/)

### Update Winget

```powershell
# Using Winget
winget update winget

# Using AppxPackage
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

### Winget Packages (Source: Microsoft Store)

```
winget install 9nksqgp7f2nh   --source msstore --accept-package-agreements --accept-source-agreements   # WhatsApp
winget install xpfftq032ptphf --source msstore --accept-package-agreements --accept-source-agreements   # UniGetUI
winget install 9nvfzpv0v0ht   --source msstore --accept-package-agreements --accept-source-agreements   # Folo
winget install 9p8ltpgcbzxd   --source msstore --accept-package-agreements --accept-source-agreements   # Wintoys
```

### Winget Packages (Source: Winget)

```
winget install Brave.Brave Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AutoHotkey.AutoHotkey Zaarrg.StremioCommunity Obsidian.Obsidian AdrienAllard.FileConverter Microsoft.PowerToys ente-io.auth-desktop Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
```

### Optional Winget Packages (Source: Winget)

```
winget install ONLYOFFICE.DesktopEditors eMClient.eMClient BlueStack.BlueStacks th-ch.YouTubeMusic --source winget --accept-package-agreements --accept-source-agreements
```

### Add Scoop Buckets

```
scoop bucket add extras
scoop bucket add versions
scoop bucket add personal https://github.com/fahim-ahmed05/scoop-bucket
```

### Scoop Packages

```
scoop install 7zip aria2 fastfetch nodejs scoop-search aimp python quicklook revouninstaller syncthing trafficmonitor-lite winaero-tweaker yt-dlp zed versions/ffmpeg-yt-dlp-nightly
```

### Optional Scoop Packages

```
scoop install mpv-git foobar2000 foobar2000-encoders localsend logitech-omm personal/clickpaste
```

## [Activate Windows](https://github.com/massgravel/Microsoft-Activation-Scripts)

```powershell
irm "https://get.activated.win" | iex
```

## [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```powershell
irm "https://christitus.com/win" | iex
```

### Tweaks

- [x] Create Restore Point
- [x] Disable Explorer Automatic Folder Discovery
- [x] Disable Wi-Fi Sense
- [x] Disable Powershell 7 Telemetry
- [x] Set Services to Manual
- [x] Disable IPv6
- [x] Prefer IPv4 over IPv6
- [x] Disable Teredo
- [x] Disable Recall
- [x] Disable Microsoft Copilot
- [x] Disable Intel MM (vPro LMS)
- [x] Disable Windows Platform Binary Table (WPBT)

### Updates

- [x] Security Settings

## Cursors

- [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip)
- [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/)

## Media Foundation Codecs

- [Download](https://www.codecguide.com/media_foundation_codecs.htm) the codecs zip file.
- Open terminal inside the extracted folder and run `Add-AppxPackage *.AppxBundle`.

## Home Folder Structure

```
~\Home
├── Apps          -> Portable apps
├── Config        -> App data
├── Data          -> File and folders
├── Dev           -> Coding projects
├── Git           -> Git repos
├── Links         -> Shortcuts to system folders
├── Shims         -> Symlinks to apps
└── Trash         -> Temp/useless files
```
