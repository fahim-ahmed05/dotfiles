# PowerShell

>
> [!IMPORTANT]
> Git and Scoop are required!
> 

## Install PowerShell Packages

```
scoop install oh-my-posh eza fzf zoxide
```

## Create Profile

```powershell
if (Test-Path $profile) { "Profile exists: $profile" } else { New-Item $profile -ItemType File -Force | Out-Null; "Created: $profile" }
```
### Profile Paths

```
~\Documents\PowerShell
├── Microsoft.PowerShell_profile.ps1     # PowerShell
└── Microsoft.VSCode_profile.ps1         # VSCode PowerShell Extension

~\Documents\WindowsPowerShell
└── Microsoft.PowerShell_profile.ps1     # Windows PowerShell
```

## Install [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

```
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF nerd-fonts/CascadiaMono-NF nerd-fonts/UbuntuMono-NF
```

## Disable Oh My Posh Update Notices

```
oh-my-posh disable notice
```
