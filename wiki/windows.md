# Windows

## Windows 11 ISO

- [Microsoft](https://www.microsoft.com/en-us/software-download/windows11)
- [UUP dump](https://uupdump.net/fetchupd.php?arch=amd64&ring=retail)

### Tools

- [Generate autounattend.xml](https://schneegans.de/windows/unattend-generator/)
- [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/home.aspx)
- [Ventoy](https://www.ventoy.net/en/download.html)

## [Activate Windows](https://github.com/massgravel/Microsoft-Activation-Scripts)

```powershell
irm "https://get.activated.win" | iex
```

## Programs

- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Internet Download Manager](https://www.internetdownloadmanager.com/download.html)

### Winget

```powershell
# Winget
winget update winget

# AppxPackage
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

#### Winget Packages (Source: Microsoft Store)

```
winget install 9nksqgp7f2nh   --source msstore --accept-package-agreements --accept-source-agreements   # WhatsApp
winget install xpfftq032ptphf --source msstore --accept-package-agreements --accept-source-agreements   # UniGetUI
winget install 9nvfzpv0v0ht   --source msstore --accept-package-agreements --accept-source-agreements   # Folo
winget install 9p8ltpgcbzxd   --source msstore --accept-package-agreements --accept-source-agreements   # Wintoys
```

#### Winget Packages (Source: Winget)

```
winget install Brave.Brave Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AutoHotkey.AutoHotkey Zaarrg.StremioCommunity Obsidian.Obsidian AdrienAllard.FileConverter Microsoft.PowerToys ente-io.auth-desktop Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
```

#### Optional Winget Packages (Source: Winget)

```
winget install ONLYOFFICE.DesktopEditors eMClient.eMClient BlueStack.BlueStacks th-ch.YouTubeMusic --source winget --accept-package-agreements --accept-source-agreements
```

### [Scoop](https://scoop.sh/)

> [!IMPORTANT]
> [Git](https://git-scm.com/download/win) is required!

#### Change Powershell Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

#### Install Scoop

```powershell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

#### Add Scoop Buckets

```
scoop bucket add extras
scoop bucket add versions
scoop bucket add personal https://github.com/fahim-ahmed05/scoop-bucket
```

#### Scoop Packages

```
scoop install 7zip aria2 fastfetch nodejs aimp python quicklook revouninstaller syncthing trafficmonitor-lite winaero-tweaker yt-dlp zed versions/ffmpeg-yt-dlp-nightly
```

#### Optional Scoop Packages

```
scoop install uv mpv-git alacritty ayugram foobar2000 foobar2000-encoders localsend logitech-omm personal/clickpaste personal/playtorrio vivetool umpv 
```

### Python

> [!IMPORTANT]
> [Python](#scoop-packages) and [uv](#optional-scoop-packages) are required!

#### Python Packages

```
uv tool install internetarchive subliminal
```

## Fonts

- [Inter](https://rsms.me/inter/download/)

> [!IMPORTANT]
> [Scoop](#scoop) is required!

### Install [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

```
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF nerd-fonts/CascadiaMono-NF nerd-fonts/UbuntuMono-NF
```

## PowerShell

### Install PowerShell

```
winget install Microsoft.PowerShell
```

### Install PowerShell Packages

> [!IMPORTANT]
> [Git](https://git-scm.com/download/win) and [Scoop](https://github.com/fahim-ahmed05/dotfiles/blob/main/wiki/windows.md#scoop) are required!

```
scoop install oh-my-posh eza fzf zoxide
```

### Create Profile

```powershell
if (Test-Path $profile) { "Profile exists: $profile" } else { New-Item $profile -ItemType File -Force | Out-Null; "Created: $profile" }
```

#### Profile Paths

```
~\Documents\PowerShell
├── Microsoft.PowerShell_profile.ps1     # PowerShell
└── Microsoft.VSCode_profile.ps1         # VSCode PowerShell Extension

~\Documents\WindowsPowerShell
└── Microsoft.PowerShell_profile.ps1     # Windows PowerShell
```

### Disable Oh My Posh Update Notices

```
oh-my-posh disable notice
```

## Network

### [DNS](https://en.wikipedia.org/wiki/Domain_Name_System)

| Provider                                                                              | IPv4                               | IPv6                                         | DoT                   | DoH                                     |
| ------------------------------------------------------------------------------------- | ---------------------------------- | -------------------------------------------- | --------------------- | --------------------------------------- |
| [Adguard](https://adguard-dns.io/en/public-dns.html) <br> Block Ads & Malware         | `94.140.14.14` <br> `94.140.15.15` | `2a10:50c0::ad1:ff` <br> `2a10:50c0::ad2:ff` | `dns.adguard-dns.com` | `https://dns.adguard-dns.com/dns-query` |
| [Quad9](https://quad9.net/service/service-addresses-and-features/) <br> Block Malware | `9.9.9.9` <br> `149.112.112.112`   | `2620:fe::fe` <br> `2620:fe::9`              | `dns.quad9.net`       | `https://dns.quad9.net/dns-query`       |

### [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol)

| Server                                             | Address               |
| -------------------------------------------------- | --------------------- |
| [NTP Pool Project](http://www.pool.ntp.org)        | `pool.ntp.org`        |
| [Cloudflare NTP](https://www.cloudflare.com/time/) | `time.cloudflare.com` |

## [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```powershell
irm "https://christitus.com/win" | iex
```

### Tweaks

- [x] Create Restore Point
- [x] Disable Wi-Fi Sense
- [x] Disable PowerShell 7 Telemetry
- [x] Set Services to Manual

## Cursors

- [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip)
- [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/)

## MPV Plugins

- [mpv-autosub](https://github.com/fahim-ahmed05/mpv-autosub)
- [ModernZ](https://github.com/Samillion/ModernZ)
- [thumbfast](https://github.com/po5/thumbfast)

## Media Foundation Codecs

- [Download](https://www.codecguide.com/media_foundation_codecs.htm) the codecs zip file.
- Open terminal inside the extracted folder and run 

```
Add-AppxPackage *.AppxBundle
```
