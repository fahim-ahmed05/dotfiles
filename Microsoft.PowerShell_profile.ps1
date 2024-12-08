# Module
Import-Module -Name Terminal-Icons

# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

# Alias
Set-Alias rm Remove-ItemSafely -Option AllScope

# Functions
function rmdeskicons {
    Remove-ItemSafely "$HOME\Desktop\*.lnk", "C:\Users\Public\Desktop\*.lnk"
    Write-Host "Desktop icons have been moved to recycle bin." -ForegroundColor "Green"
}

# PowerShell
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Green'
    String    = 'DarkCyan'
}

# Terminal
function reloadterminal { 
    exit & wt
}

# Winget
function ws {
    Write-Host "`nWinGet packages`n" -ForegroundColor "Cyan" 
    winget search @args

    Write-Host "`nChocolatey packages`n" -ForegroundColor "Cyan"
    choco search @args
    
    Write-Host "`nScoop packages`n" -ForegroundColor "Cyan"
    scoop search @args
}

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5
    rmdeskicons
}

function wu {
    Write-Host "`nUpdating WinGet packages...`n" -ForegroundColor "Cyan"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating Scoop packages...`n" -ForegroundColor "Cyan"
    scoop update

    Write-Host "`nUpdating Chocolatey packages...`n" -ForegroundColor "Cyan"
    gsudo choco upgrade all -y

    Write-Host "`nUpdating Pip binary...`n" -ForegroundColor "Cyan"
    python.exe -m pip install --upgrade pip

    Write-Host "`nUpdating Pipx packages...`n" -ForegroundColor "Cyan"
    pipx upgrade-all
    
    Write-Host "`nUpdating MSYS2 packages...`n" -ForegroundColor "Cyan"
    & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$PWD' && pacman -Syu --noconfirm && paccache -r"

    Write-Host "`nUpdating Windows system`n" -ForegroundColor "Cyan"
    gsudo Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose

    Write-Host "`n"
    rmdeskicons
}

# Repair
function checkwindowshealth {
    gsudo DISM /Online /Cleanup-Image /CheckHealth
    gsudo DISM /Online /Cleanup-Image /ScanHealth
}

function repairwindowshealth {
    gsudo sfc /scannow
    gsudo DISM /Online /Cleanup-Image /RestoreHealth
}

# Network
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS cache has been removed." -ForegroundColor "Green"
}

function getpubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# File
function touch { param($name) New-Item -ItemType "file" -Path . -Name $name }
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

# HasteBin
function hb {
    if ($args.Length -eq 0) {
        Write-Error "No file path specified."
        return
    }
    
    $FilePath = $args[0]
    
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    }
    else {
        Write-Error "File path does not exist."
        return
    }
    
    $uri = "http://bin.christitus.com/documents"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Set-Clipboard $url
        Write-Output $url
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

# Node
fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression

# Scoop
Invoke-Expression (&scoop-search --hook)

# Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# MSYS2
function ucr {
    param (
        [string]$Command = $null
    )

    $currentDir = Get-Location

    if ($Command) {
        & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$currentDir' && $Command"
    } else {
        & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$currentDir' && exec bash"
    }
}
