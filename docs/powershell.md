# PowerShell

#### Change Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

#### Install PowerShell Packages

```powershell
winget install eza-community.eza junegunn.fzf ajeetdsouza.zoxide JanDeDobbeleer.OhMyPosh Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
wt oh-my-posh disable notice
```

#### Create Profile

```powershell
if (Test-Path $profile) { "Profile exists at: $profile" } else { "Profile does not exist. Creating..."; New-Item -Path $profile -Type File -Force; "Profile created at: $profile" }
```
Profile paths:
- PowerShell: ``~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1``
- VSCode PowerShell Extension: ``~\Documents\PowerShell\Microsoft.VSCode_profile.ps1``
- Windows PowerShell: ``~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1``

#### Install [Nerd Fonts](https://www.nerdfonts.com/)
⚠️ **[Scoop](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/windows.md#install-scoop) & Git required**
```PowerShell
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
    scoop install nerd-fonts/UbuntuMono-NF
```

