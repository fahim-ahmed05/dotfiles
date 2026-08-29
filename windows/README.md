# Windows

## Install Windows

### Windows 11 ISO

- [Microsoft](https://www.microsoft.com/en-us/software-download/windows11)
- [UUP dump](https://uupdump.net/fetchupd.php?arch=amd64&ring=retail)

### Tools

- [Ventoy](https://www.ventoy.net/en/download.html)
- [Microsoft Update Catalog](https://www.catalog.update.microsoft.com/home.aspx)
- [Generate autounattend.xml](https://schneegans.de/windows/unattend-generator/)

## [Activate Windows](https://github.com/massgravel/Microsoft-Activation-Scripts)

```
irm "https://get.activated.win" | iex
```

## Programs

- [Git](https://git-scm.com/download/win)
- [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Internet Download Manager](https://www.internetdownloadmanager.com/download.html)

### Winget

```
# Winget
winget update winget

# AppxPackage
Add-AppxPackage -Path "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForceApplicationShutdown
```

#### Winget Packages (Source: Microsoft Store)

```
# winget install UniGetUI FluentFlyout Wintoys --source msstore --accept-package-agreements --accept-source-agreements

winget install xpfftq032ptphf 9n45nsm4tnbp 9p8ltpgcbzxd --source msstore --accept-package-agreements --accept-source-agreements
```

#### Winget Packages (Source: Winget)

```
winget install Brave.Brave Mozilla.Firefox xanderfrangos.twinkletray HermannSchinagl.LinkShellExtension Notepad++.Notepad++ voidtools.Everything.Alpha qBittorrent.qBittorrent Flow-Launcher.Flow-Launcher SumatraPDF.SumatraPDF AdrienAllard.FileConverter Microsoft.PowerToys ente-io.auth-desktop Cloudflare.Warp Tonec.InternetDownloadManager --source winget --accept-package-agreements --accept-source-agreements
```

#### Optional Winget Packages (Source: Winget)

```
winget install ONLYOFFICE.DesktopEditors eMClient.eMClient --source winget --accept-package-agreements --accept-source-agreements
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
scoop install 7zip aria2 fastfetch bt aimp quicklook revouninstaller uv mise mpv-git luajit alacritty telegram syncthing winaero-tweaker versions/yt-dlp-nightly versions/ffmpeg-yt-dlp-nightly foobar2000 foobar2000-encoders localsend logitech-omm personal/clickpaste personal/winhance antigravity-ide
```

#### Optional Scoop Packages

```
scoop install scoop install pear-desktop mrrss trafficmonitor-lite
```

### [Python](https://www.python.org/)

> [!IMPORTANT]
> [uv](#scoop-packages) is required!

#### Install Python

```
uv python install --default
```

#### Python Packages

```
uv tool install internetarchive
uv tool install subliminal
uv tool install git+https://github.com/fahim-ahmed05/cineindex.git
```

### Node.js

> [!IMPORTANT]
> [mise](#scoop-packages) is required!

#### Install Node.js

```
mise use -g node@lts
```

## Fonts

> [!IMPORTANT]
> [Scoop](#scoop) is required!

### Install [Inter](https://rsms.me/inter/download/) font

```
scoop install personal/inter-font 
```

### Install [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

```
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF nerd-fonts/CascadiaMono-NF nerd-fonts/UbuntuMono-NF
```

## PowerShell

> [!IMPORTANT]
> [Git](https://git-scm.com/download/win) and [Scoop](https://github.com/fahim-ahmed05/dotfiles/blob/main/wiki/windows.md#scoop) are required!

### Install PowerShell

```
scoop install pwsh
```

### Install PowerShell Packages

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

## Cursors

- [Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Original-Ice-Windows.zip)
- [Posy's Cursor (Default + Extras)](https://www.michieldb.nl/other/cursors/)

## Tweak Tools

### [Windows Utility](https://github.com/ChrisTitusTech/winutil)

```
irm "https://christitus.com/win" | iex
```

## MPV Plugins

- [ModernZ](https://github.com/Samillion/ModernZ)
- [thumbfast](https://github.com/po5/thumbfast)
- [mpv-autosub](https://github.com/fahim-ahmed05/mpv-autosub)

> [!IMPORTANT]
> [Git](https://git-scm.com/download/win) is required!

```
mkdir ~/Git -force
cd ~/Git
git clone https://github.com/Samillion/ModernZ.git
git clone https://github.com/po5/thumbfast.git
git clone git@github.com:fahim-ahmed05/mpv-autosub.git
```

## Git Repositories

> [!IMPORTANT]
> [Git](https://git-scm.com/download/win) is required!

```
mkdir ~/Git -force
cd ~/Git
git clone git@github.com:fahim-ahmed05/fast-scoop-search.git
git clone git@github.com:fahim-ahmed05/dotmngr.git
git clone git@github.com:fahim-ahmed05/scoop-bucket.git
```
