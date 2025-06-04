# PowerShell

#### Change Execution Policy

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

#### Install [Oh My Posh](https://ohmyposh.dev/docs/installation/windows)

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget && wt oh-my-posh disable notice
```

#### Create Profile

```powershell
if (Test-Path $profile) { "Profile exists at: $profile" } else { "Profile does not exist. Creating..."; New-Item -Path $profile -Type File -Force; "Profile created at: $profile" }
```
Profile paths:
- PowerShell: ``Documents\PowerShell\Microsoft.PowerShell_profile.ps1``
- VSCode PowerShell Extension: ``Documents\PowerShell\Microsoft.VSCode_profile.ps1``
- Windows PowerShell: ``Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1``

#### Install [Scoop](https://scoop.sh/)
```PowerShell
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

#### Install [Nerd Fonts](https://www.nerdfonts.com/)
```PowerShell
    scoop bucket add nerd-fonts
    scoop install nerd-fonts/JetBrainsMono-NF
    scoop install nerd-fonts/CascadiaMono-NF
    scoop install nerd-fonts/UbuntuMono-NF
```

## `unzip` - [Unzip files using 7-Zip](https://github.com/fahim-ahmed05/dotfiles/blob/main/powershell/functions/CustomFunctions.ps1)

```PowerShell
# Extract a specific archive to a folder named after the archive
uzip archive.zip

# Extract all .zip archives in the current directory
uzip zip

# Extract all archives matching a wildcard pattern (e.g., all zip files starting with "test")
uzip test*.zip

# Extract a specific archive to a custom folder
uzip archive.zip C:\ExtractHere

# Extract all .rar files in the current directory to a custom folder
uzip rar D:\MyExtractedRars

# Extract an archive even if the target folder already exists (overwrite)
uzip archive.zip -Force
uzip archive.zip -F

# Extract all archives matching a pattern with allowed extensions
uzip myarchive*

# Extract all archives in the current directory
uzip

# Extract an archive using relative or absolute path
uzip .\folder\archive.7z
uzip C:\Downloads\archive.7z

# Extract archives matching a wildcard pattern
uzip *.7z

# Extract archives of multiple types (using extension shortcut)
uzip 7z

# Extract an archive with spaces in the name
uzip "my archive.zip"

# Force extract all .zip files even if folders exist
uzip zip -Force
uzip zip -F
```