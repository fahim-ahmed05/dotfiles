# PowerShell

> [!IMPORTANT]
[Git](https://git-scm.com/download/win) and [Scoop](https://github.com/fahim-ahmed05/dotfiles/blob/main/wiki/windows.md#install-scoop) required

## Install PowerShell Packages

```powershell
scoop install oh-my-posh eza fzf zoxide; wt -w "oh-my-posh disable notice"
```

## Create Profile

```powershell
if (Test-Path $profile) { "Profile exists: $profile" } else { New-Item $profile -ItemType File -Force | Out-Null; "Created: $profile" }
```
### Profile Paths

```powershell
~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1        # PowerShell
~\Documents\PowerShell\Microsoft.VSCode_profile.ps1            # VSCode PowerShell Extension
~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 # Windows PowerShell
```

## Install [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

```powershell
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF nerd-fonts/CascadiaMono-NF nerd-fonts/UbuntuMono-NF
```
