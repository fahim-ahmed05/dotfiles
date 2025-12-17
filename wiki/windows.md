# Windows

### [Activate Windows](https://github.com/massgravel/Microsoft-Activation-Scripts)

```powershell
irm "https://get.activated.win" | iex
```

### [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```powershell
irm "https://christitus.com/win" | iex
```

### Programs

- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Code](https://code.visualstudio.com/)

### Update Winget

```powershell
winget upgrade winget
```

### Winget Packages (Source: Microsoft Store)

```powershell
winget install 9nksqgp7f2nh --source msstore --accept-package-agreements --accept-source-agreements   # WhatsApp
winget install xpfftq032ptphf --source msstore --accept-package-agreements --accept-source-agreements # UniGetUI
winget install 9nvfzpv0v0ht --source msstore --accept-package-agreements --accept-source-agreements   # Folo
winget install 9p8ltpgcbzxd --source msstore --accept-package-agreements --accept-source-agreements   # Wintoys
```

### Winget Packages (Source: Winget)

```powershell
winget install Microsoft.PowerShell Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AutoHotkey.AutoHotkey Stremio.Stremio Obsidian.Obsidian QL-Win.QuickLook AdrienAllard.FileConverter AIMP.AIMP Brave.Brave eMClient.eMClient Microsoft.PowerToys ente-io.auth-desktop ONLYOFFICE.DesktopEditors Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
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
├── apps     -> portable/user managed apps
├── etc      -> shortcuts to different system folders
├── files    -> files and folders created by user
├── persist  -> user managed app files
├── shims    -> symlinks to apps that'll be available in path
└── themes   -> files related to theming
```
