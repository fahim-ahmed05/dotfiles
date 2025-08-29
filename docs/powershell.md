| [Browser](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/browser.md) | [Network](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/network.md) | [PowerShell](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/powershell.md) | [Windows](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/windows.md) |
|------|------|------|------|

---

# PowerShell

### Change Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

### Install PowerShell Packages

```powershell
winget install JanDeDobbeleer.OhMyPosh eza-community.eza junegunn.fzf ajeetdsouza.zoxide Microsoft.PowerShell Fastfetch-cli.Fastfetch --source winget --accept-package-agreements --accept-source-agreements; wt -w "oh-my-posh disable notice"
```

### Create Profile

```powershell
if (Test-Path $profile) { "Profile exists: $profile" } else { New-Item $profile -ItemType File -Force | Out-Null; "Created: $profile" }
```
Profile paths:
- PowerShell: `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- VSCode PowerShell Extension: `~\Documents\PowerShell\Microsoft.VSCode_profile.ps1`
- Windows PowerShell: `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

### Install [Nerd Fonts](https://www.nerdfonts.com/)
| [Scoop](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/windows.md#install-scoop) & [Git](https://git-scm.com/download/win) required |
|--------------------------------------------------------------------|
```powershell
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF nerd-fonts/CascadiaMono-NF nerd-fonts/UbuntuMono-NF
```

---

| [Browser](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/browser.md) | [Network](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/network.md) | [PowerShell](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/powershell.md) | [Windows](https://github.com/fahim-ahmed05/dotfiles/blob/main/docs/windows.md) |
|------|------|------|------|

