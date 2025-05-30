# My dotfiles

I use these daily! 👀

### Violentmonkey

| Script Name                     | Description                                    |                                                                  |
|---------------------------------|------------------------------------------------|:----------------------------------------------------------------:|
| [Video Speed Control](https://github.com/fahim-ahmed05/userscript-videospeedcontrol) | Control video speed (1x to 5x) with keyboard shortcuts. | [Install](https://github.com/fahim-ahmed05/userscript-videospeedcontrol/raw/main/videospeedcontrol.user.js) |
| [Return YouTube Dislike](https://returnyoutubedislike.com/) | Restores YouTube dislike counts. | [Install](https://github.com/Anarios/return-youtube-dislike/raw/main/Extensions/UserScript/Return%20Youtube%20Dislike.user.js) |

### Powershell

#### Change Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

#### Update [PSReadLine](https://github.com/PowerShell/PSReadLine#installation) with admin privilege

```powershell
Install-Module -Name PowerShellGet -Force
Exit

Install-Module PSReadLine -AllowPrerelease -Force
```

#### Install [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4#install-powershell-using-winget-recommended)

```powershell
winget install --id Microsoft.PowerShell --source winget
```

#### Install [PS packages](https://www.powershellgallery.com/) with admin privilege

| Package Name                       | Description                                                                                      | Installation Command                                                   |
|------------------------------------|------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| [Recycle](https://www.powershellgallery.com/packages/Recycle)       | A PowerShell module for managing the Recycle Bin.                                                   | `Install-Module -Name Recycle -RequiredVersion 1.5.0`                  |
| [Terminal Icons](https://github.com/devblackops/Terminal-Icons)     | Adds file and folder icons to PowerShell.                                                           | `Install-Module -Name Terminal-Icons -Repository PSGallery`            |
| [Z](https://www.powershellgallery.com/packages/z)                   | Directory jumping based on frequency and recent access.                                              | `Install-Module -Name z -AllowClobber`                                 |


#### Install [Oh My Posh](https://ohmyposh.dev/docs/installation/windows)

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget && oh-my-posh disable notice
```

#### Create Profile

```powershell
if (Test-Path $profile) { "Profile exists at: $profile" } else { "Profile does not exist. Creating..."; New-Item -Path $profile -Type File -Force; "Profile created at: $profile" }
```
Profile paths:
- ``Documents\PowerShell\Microsoft.PowerShell_profile.ps1``
- ``Documents\PowerShell\Microsoft.VSCode_profile.ps1``
- ``Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1``

### Browser Extensions

|   Extension  |   Firefox   |    Chrome  |   Edge   |   Shortcut  |
| :----------- | :---------: | :--------: | :------: | :---------- |
| **Bitwarden Password Manager** | [Install](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/) | [Install](https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb) | [Install](https://microsoftedge.microsoft.com/addons/detail/bitwarden-password-manage/jbkfoedolllekgbhcbcoahefnbanhhlh) | **Open vault popup:** `Ctrl + Shift + Y`<br> **Open vault in sidebar:** `Alt + Shift + Y`<br> **Autofill last used login:** `Ctrl + Shift + L`<br> **Generate & copy new password:** `Ctrl + Shift + 9` |
| **Dark Reader** | [Install](https://addons.mozilla.org/en-US/firefox/addon/darkreader/) | [Install](https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh) | [Install](https://microsoftedge.microsoft.com/addons/detail/dark-reader/ifoakfbpdcdoeenechcleahebpibofpc) | **Menu popup:** `Alt + Shift + A`<br> **Toggle current site:** `Alt + Shift + D` |
| **Enhancer for YouTube** | [Install](https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/) | [Install](https://chromewebstore.google.com/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle) | [Install](https://microsoftedge.microsoft.com/addons/detail/enhancer-for-youtube%E2%84%A2/dlgfaleeejmphhnemjgiaekdbonkagkd) | **Decrease playback speed:** `Alt + ,`<br> **Increase playback speed:** `Alt + .`<br> **Set default playback speed:** `Ctrl + .`<br> **Reset to normal speed:** `Ctrl + ,` |
| **IDM Integration Module** | [Install](https://addons.mozilla.org/en-US/firefox/addon/tonec-idm-integration-module/) | [Install](https://chromewebstore.google.com/detail/idm-integration-module/ngpampappnmepgilojfohadhhmbhlaek) | [Install](https://microsoftedge.microsoft.com/addons/detail/idm-integration-module/llbjbkhnmlidjebalopleeepgdfgcpec) | N/A |
| **SponsorBlock for YouTube** | [Install](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/) | [Install](https://chromewebstore.google.com/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone) | [Install](https://microsoftedge.microsoft.com/addons/detail/sponsorblock-for-youtube-/mbmgnelfcpoecdepckhlhegpcehmpmji) | N/A |
| **uBlock Origin** | [Install](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) | [Install](https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm) | [Install](https://microsoftedge.microsoft.com/addons/detail/ublock-origin/odfafepnkmbhccpbejgmiehpchacaeak) | **Toolbar popup:** `Alt + Shift + U`<br> **Element picker mode:** `Alt + Shift + P` |
| **Violentmonkey** | [Install](https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/) | [Install](https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag) | [Install](https://microsoftedge.microsoft.com/addons/detail/violentmonkey/eeagobfjdenkkddmbclomhiblgggliao) | N/A |
| **Web Scrobbler** | [Install](https://addons.mozilla.org/en-US/firefox/addon/web-scrobbler/) | [Install](https://chromewebstore.google.com/detail/web-scrobbler/hhinaapppaileiechjoiifaancjggfjm) | [Install](https://microsoftedge.microsoft.com/addons/detail/web-scrobbler/obiekdelmkmlgnhddmmnpnfhngejbnnc) | N/A |
| **Firefox Multi-Account Containers** | [Install](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/) | N/A | N/A | N/A |
| **Picture-in-Picture Extension** | N/A | [Install](https://chromewebstore.google.com/detail/picture-in-picture-extens/hkgfoiooedgoejojocmhlaklaeopbecg) | N/A | **Activate:** `Alt + P` |
| **MAL-Sync** | [Install](https://addons.mozilla.org/en-US/firefox/addon/mal-sync/) | [Install](https://chromewebstore.google.com/detail/mal-sync/kekjfbackdeiabghhcdklcdoekaanoel) | N/A | **Menu popup:** `Alt + M` |
| **Floccus Bookmark Sync** | [Install](https://addons.mozilla.org/en-US/firefox/addon/floccus/) | [Install](https://chromewebstore.google.com/detail/floccus-bookmarks-sync/fnaicdffflnofjppbagibeoednhnbjhg) | [Install](https://microsoftedge.microsoft.com/addons/detail/gjkddcofhiifldbllobcamllmanombji) | N/A |
| **Snowflake** | [Install](https://addons.mozilla.org/en-US/firefox/addon/torproject-snowflake/) | [Install](https://chromewebstore.google.com/detail/snowflake/mafpmfcccpbjnhfhjnllmmalhifmlcie) | N/A | N/A |
| **Google Dictionary** | N/A | [Install](https://chromewebstore.google.com/detail/google-dictionary-by-goog/mgijmajocgfcbeboacabfgobmjgjcoja) | N/A | N/A |
| **Proton VPN** | [Install](https://addons.mozilla.org/en-US/firefox/addon/proton-vpn-firefox-extension/) | [Install](https://chromewebstore.google.com/detail/proton-vpn-fast-secure/jplgfhpmjnbigmhklmmbgecoobifkmpa) | N/A | N/A |
| **Google Docs Offline** | N/A | [Install](https://chromewebstore.google.com/detail/google-docs-offline/ghbmnnjooekpmoecnnnilnnbdlolhkhi) | N/A | N/A |

### Programs

[Revo Uninstaller](https://www.revouninstaller.com/revo-uninstaller-free-download/), [Twinkle Tray](https://apps.microsoft.com/detail/9pljwwsv01lk), [Python](https://www.python.org/downloads/), [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm), [Git](https://git-scm.com/download/win), [Visual Studio Code](https://code.visualstudio.com/), [Traffic Monitor](https://github.com/zhongyang219/TrafficMonitor/releases), [Winaero Tweaker](https://winaero.com/download-winaero-tweaker/), [Firefox Nightly](https://www.mozilla.org/en-US/firefox/channel/desktop/)

### [Setup Script](https://github.com/fahim-ahmed05/dotfiles/blob/main/ShellScripts/WindowsSetup.ps1)

```powershell
iwr "https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/ShellScripts/WindowsSetup.ps1" | iex
```

### Activate Windows ([Massgrave](https://github.com/massgravel/Microsoft-Activation-Scripts))

```powershell
irm https://get.activated.win | iex
```

### Cursors

[Bibata Original Ice](https://github.com/ful1e5/Bibata_Cursor), [Posy's Cursor (Default + Extras)](http://www.michieldb.nl/other/cursors/)

### Fonts

[Inter](https://rsms.me/inter/download/), [CascadiaCode-NF, JetBrainsMono-NF, UbuntuSans-NF](https://github.com/ryanoasis/nerd-fonts/releases), [SolaimanLipi, AdorshoLipi](https://www.omicronlab.com/bangla-fonts.html), [Ekushey Lal Salu Normal](https://ekushey.org/fonts/)

### DNS

| **Provider**   | **IPv4**                     | **IPv6**                             | **DOT**                        | **DOH**                                           |
|----------------|------------------------------|--------------------------------------|--------------------------------|---------------------------------------------------|
| **Adguard** <br> *Block Ads & Malware*  | `94.140.14.14`<br>`94.140.15.15` | `2a10:50c0::ad1:ff`<br>`2a10:50c0::ad2:ff` | `dns.adguard-dns.com`          | `https://dns.adguard-dns.com/dns-query`           |
| **Quad9** <br> *Block Malware*     | `9.9.9.9`<br>`149.112.112.112` | `2620:fe::fe`<br>`2620:fe::9`       | `dns.quad9.net`                | `https://dns.quad9.net/dns-query`                 |

### [Content Filters](https://github.com/fahim-ahmed05/dotfiles/tree/main/ContentFilters)

| **Name**                          | **Description**                            | **URL**                                                             |
|-----------------------------------|--------------------------------------------|---------------------------------------------------------------------|
| [uBlock Remove Annoyances](https://github.com/fahim-ahmed05/dotfiles/blob/main/ContentFilters/ublock-remove-annoyances.txt) | A filter list for removing common annoyances on websites. | `https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/ContentFilters/ublock-remove-annoyances.txt` |
| [uBlock YouTube Annoyances](https://github.com/fahim-ahmed05/dotfiles/blob/main/ContentFilters/ublock-youtube-annoyances.txt) | A filter list targeting YouTube-specific annoyances. | `https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/ContentFilters/ublock-youtube-annoyances.txt` |

**Other Filters:** [Hagezi](https://github.com/hagezi/dns-blocklists)

### Wallpapers

[Unsplash](https://unsplash.com/collections/flfrGRQpfgU/wallpapers), [Google Photos](https://photos.app.goo.gl/KBUxAoErDPASNR182), [GitHub](https://github.com/fahim-ahmed05/dotfiles/tree/main/Wallpapers), [Basic Apple Guy](https://basicappleguy.com/basicappleblog/tag/Wallpaper)

### Credits

- https://github.com/yokoffing/Betterfox
- https://github.com/ChrisTitusTech/powershell-profile
- https://www.reddit.com/r/uBlockOrigin/wiki/solutions/youtube/
