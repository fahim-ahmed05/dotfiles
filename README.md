# My dotfiles
I use these daily! 👀

### Violentmonkey
Click on script name and select Install +Close.
1. [Video Speed 2x](https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/main/videoSpeed2x.user.js)
2. [Return YouTube Dislike](https://github.com/Anarios/return-youtube-dislike/raw/main/Extensions/UserScript/Return%20Youtube%20Dislike.user.js)

#### Note
- Install page might take 1-2 sec to appear. So, wait after clicking.
- If you face update issue then reinstall. 

### Firefox
###### user.js
1. Download [user.js](https://github.com/fahim-ahmed05/dotfiles/blob/main/Firefox/user.js) file 
2. Open About Profiles page. Url `about:profiles`
3. Goto default profile's root directory
4. Copy and paste downloaded user.js file
5. Click on restart normally button on About Profiles page.

###### userChrome.css
1. Download [userChrome.css](https://github.com/fahim-ahmed05/dotfiles/blob/main/Firefox/userChrome.css) file
2. Put it inside profile_folder/chrome
3. Restart the browser.

### Powershell
###### Execution Policy
- Change to unrestricted
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

###### Packages
1. [Recycle](https://www.powershellgallery.com/packages/Recycle) `Install-Module -Name Recycle`
2. [Terminal Icons](https://github.com/devblackops/Terminal-Icons) `Install-Module -Name Terminal-Icons -Repository PSGallery`
3. [Z](https://www.powershellgallery.com/packages/z) `Install-Module -Name z -AllowClobber`

###### Prompt
- Install Oh My Posh
```
winget install JanDeDobbeleer.OhMyPosh -s winget
```

###### Profile
1. Open powershell/terminal
2. Type `test-path $profile` to check if you have a profile or not
3. If you have a profile then type `$profile` to know the profile path
4. If you have a profile then goto the directory and open the profile file with a text editor
5. If not to create a profile file type `New-Item -Path $profile -Type File -Force` 
6. Open [my powershell profile file](https://github.com/fahim-ahmed05/dotfiles/blob/main/Microsoft.PowerShell_profile.ps1) and copy paste into yours the save the file and type `. $Profile` to reload the profile.

#### Note
- Follow the chronology!! 
- Update [PSReadLine](https://github.com/PowerShell/PSReadLine), if using powershell 5.
- Change Windows Terminal's font to a nerd font.
- Execute `oh-my-posh disable notice`

### Browser Extensions
###### Download Links
1. Bitwarden Password Manager [Firefox](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/) [Chrome](https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb) [Edge](https://microsoftedge.microsoft.com/addons/detail/bitwarden-password-manage/jbkfoedolllekgbhcbcoahefnbanhhlh)
2. Dark Reader [Firefox](https://addons.mozilla.org/en-US/firefox/addon/darkreader/) [Chrome](https://chromewebstore.google.com/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh) [Edge](https://microsoftedge.microsoft.com/addons/detail/dark-reader/ifoakfbpdcdoeenechcleahebpibofpc)
3. Enhancher for YouTube [Firefox](https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/) [Chrome](https://chromewebstore.google.com/detail/enhancer-for-youtube/ponfpcnoihfmfllpaingbgckeeldkhle) [Edge](https://microsoftedge.microsoft.com/addons/detail/enhancer-for-youtube%E2%84%A2/dlgfaleeejmphhnemjgiaekdbonkagkd)
4. IDM Integration Module [Firefox](https://addons.mozilla.org/en-US/firefox/addon/tonec-idm-integration-module/) [Chrome](https://chromewebstore.google.com/detail/idm-integration-module/ngpampappnmepgilojfohadhhmbhlaek) [Edge](https://microsoftedge.microsoft.com/addons/detail/idm-integration-module/llbjbkhnmlidjebalopleeepgdfgcpec)
5. Sponsorblock for YouTube [Firefox](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/) [Chrome](https://chromewebstore.google.com/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone) [Edge](https://microsoftedge.microsoft.com/addons/detail/sponsorblock-for-youtube-/mbmgnelfcpoecdepckhlhegpcehmpmji)
6. uBlock Origin [Firefox](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) [Chrome](https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm?hl=en) [Edge](https://microsoftedge.microsoft.com/addons/detail/ublock-origin/odfafepnkmbhccpbejgmiehpchacaeak)
7. Violentmonkey [Firefox](https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/) [Chrome](https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag) [Edge](https://microsoftedge.microsoft.com/addons/detail/violentmonkey/eeagobfjdenkkddmbclomhiblgggliao)
8. Web Scrobbler [Firefox](https://addons.mozilla.org/en-US/firefox/addon/web-scrobbler/) [Chrome](https://chromewebstore.google.com/detail/web-scrobbler/hhinaapppaileiechjoiifaancjggfjm?hl=en) [Edge](https://microsoftedge.microsoft.com/addons/detail/web-scrobbler/obiekdelmkmlgnhddmmnpnfhngejbnnc)
9. Firefox Multi-Account Containers [Firefox](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/)
10. Picture-in-Picture Extension [Chrome](https://chromewebstore.google.com/detail/picture-in-picture-extens/hkgfoiooedgoejojocmhlaklaeopbecg?hl=en)

###### Shortcut Keys
- Bitwarden Password Manager
  - Open vault popup: `Ctrl + Shit + Y`
  - Open vault in sidebar: `Alt + Shift + Y`
  - Autofill the last used login: `Ctrl + Shift + L`
  - Generate and copy a new random password: `Ctrl + Shift + 9`
- Dark Reader
  - Activate menu popup: `Alt + Shift + A`
  - Toggle current site: `Alt + Shift + D`
- Enhancher for YouTube
  - Decrease the playback speed: `Alt + Comma`
  - Increase the playback speed: `Alt + Period`
  - Select the default playback speed: `Ctrl + Period`
  - Select the normal playback speed: `Ctrl + Comma`
- uBlock Origin
  - Activate toolbar popup: `Alt + Shift + U`
  - Enter element picker mode: `Alt + Shift + P`

### Windows
###### Programs
[Firefox](https://www.mozilla.org/en-US/firefox/new/), [Revo Uninstaller](https://www.revouninstaller.com/revo-uninstaller-free-download/), [Twinkle Tray](https://apps.microsoft.com/detail/9pljwwsv01lk), [Python](https://www.python.org/downloads/), [K-Lite Codec Pack](https://codecguide.com/download_k-lite_codec_pack_standard.htm), [Git](https://git-scm.com/download/win), [Visual Studio Code](https://code.visualstudio.com/), [Traffic Monitor](https://github.com/zhongyang219/TrafficMonitor/releases), [Brave](https://brave.com/), 7zip, Ente Auth, Notepad++, ProtonVPN, OnlyOffice, Everything, FileConverter, gSudo, SyncTrayzor, Gpg4win IDM, Stremio, qBittorrent, QuickLook, Bitwarden, Notion, Fastfetch, Flow Launcher, FFmpeg, OhMyPosh, SumatraPDF, Kdenlive, PowerToys

###### Pipx Packages
yt-dlp, spotdl

###### Setup Script
- Manually install Python, Git
- Install powershell packages
- Now run the [script](https://github.com/fahim-ahmed05/dotfiles/blob/main/windowsSetup.ps1)

###### Cursors
[Bibata](https://github.com/ful1e5/Bibata_Cursor), [Posy](http://www.michieldb.nl/other/cursors/)

###### Fonts
[Inter](https://rsms.me/inter/download/), [FiraCode-NF, CascadiaCode-NF, JetBrainsMono-NF, Meslo-NF, SpaceMono-NF, UbuntuSans-NF](https://github.com/ryanoasis/nerd-fonts/releases), [SolaimanLipi, AdorshoLipi](https://www.omicronlab.com/bangla-fonts.html), [Ekushey Lal Salu Normal](https://ekushey.org/fonts/)

### DNS
| **Provider**   | **IPv4**                     | **IPv6**                             | **DOT**                        | **DOH**                                           |
|----------------|------------------------------|--------------------------------------|--------------------------------|---------------------------------------------------|
| **Adguard** <br> *Block Ad & Malware*  | `94.140.14.14`<br>`94.140.15.15` | `2a10:50c0::ad1:ff`<br>`2a10:50c0::ad2:ff` | `dns.adguard-dns.com`          | `https://dns.adguard-dns.com/dns-query`           |
| **Mullvad** <br> *Block Ad & Malware*   | `194.242.2.4`                            | `2a07:e340::4`                                    | `base.dns.mullvad.net`         | `https://base.dns.mullvad.net/dns-query`          |
| **Cloudflare** <br> *Block Malware* | `1.1.1.2`<br>`1.0.0.2`       | `2606:4700:4700::1112`<br>`2606:4700:4700::1002` | `security.cloudflare-dns.com`  | `https://security.cloudflare-dns.com/dns-query`   |
| **Quad9** <br> *Block Malware*     | `9.9.9.9`<br>`149.112.112.112` | `2620:fe::fe`<br>`2620:fe::9`       | `dns.quad9.net`                | `https://dns.quad9.net/dns-query`                 |


### Tweaks
###### Disable IDM Update Check:
- Open regedit & goto `Computer\HKEY_CURRENT_USER\Software\DownloadManager`
- Double click on `LstCheck` & change the year value to `99`.

### Credits
- https://github.com/yokoffing/Betterfox
- https://github.com/ChrisTitusTech/powershell-profile
- https://www.reddit.com/r/uBlockOrigin/wiki/solutions/youtube/