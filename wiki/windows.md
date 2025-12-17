# Windows

### Change Powershell Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Install [Scoop](https://scoop.sh/)

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

### Programs

- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Code](https://code.visualstudio.com/)

#### Update Winget

```powershell
winget upgrade winget
```

#### Winget Packages (Source: Microsoft Store)

```powershell
winget install 9nksqgp7f2nh --source msstore --accept-package-agreements --accept-source-agreements   # WhatsApp
winget install xpfftq032ptphf --source msstore --accept-package-agreements --accept-source-agreements # UniGetUI
winget install 9nvfzpv0v0ht --source msstore --accept-package-agreements --accept-source-agreements   # Folo
winget install 9p8ltpgcbzxd --source msstore --accept-package-agreements --accept-source-agreements   # Wintoys
```

#### Winget Packages (Source: Winget)

```powershell
winget install Microsoft.PowerShell Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AutoHotkey.AutoHotkey Zaarrg.StremioCommunity Obsidian.Obsidian AdrienAllard.FileConverter Microsoft.PowerToys ente-io.auth-desktop Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
```

#### Optional Winget Packages (Source: Winget)

```powershell
winget install ONLYOFFICE.DesktopEditors eMClient.eMClient BlueStack.BlueStacks th-ch.YouTubeMusic --source winget --accept-package-agreements --accept-source-agreements
```
#### Scoop Packages

```powershell
scoop install 7zip aria2 fastfetch nodejs scoop-search aimp ffmpeg-yt-dlp-nightly python quicklook revouninstaller syncthing trafficmonitor-lite winaero-tweaker yt-dlp zed
```

#### Optional Scoop Packages

```powershell
scoop install mpv-git foobar2000 foobar2000-encoders clickpaste localsend logitech-omm 
```

### [Activate Windows](https://github.com/massgravel/Microsoft-Activation-Scripts)

```powershell
irm "https://get.activated.win" | iex
```

### [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```powershell
irm "https://christitus.com/win" | iex
```
#### Tweaks
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

#### Updates
- [x] Security Settings

### Cursors

- [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip)
- [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/)

### Media Foundation Codecs

- [Download](https://www.codecguide.com/media_foundation_codecs.htm) the codecs zip file.
- Open terminal inside the extracted folder and run `Add-AppxPackage *.AppxBundle`.

### Custom Folder Structure

```
~\home
├── apps     -> portable/user managed apps
├── etc      -> shortcuts to different system folders
├── files    -> files and folders created by user
├── persist  -> user managed app files
├── shims    -> symlinks to apps that'll be available in path
└── themes   -> files related to theming
```
