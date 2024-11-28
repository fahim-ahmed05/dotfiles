# Module
Import-Module -Name Terminal-Icons

# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

# Alias
Set-Alias rm Remove-ItemSafely -Option AllScope

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
    Write-Host "`nSearching WinGet database...`n" -ForegroundColor "Cyan" 
    winget search @args

    Write-Host "`nSearching Chocolatey database...`n" -ForegroundColor "Cyan"
    choco search @args
    
    Write-Host "`nSearching Scoop database...`n" -ForegroundColor "Cyan"
    scoop search @args
}

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5
    Remove-ItemSafely "$HOME\Desktop\*.lnk", "C:\Users\Public\Desktop\*.lnk"
}

function wul { 
    Write-Host "`nChecking updates for WinGet packages...`n" -ForegroundColor "Cyan"
    winget upgrade --include-pinned

    Write-Host "`nChecking updates for Scoop packages...`n" -ForegroundColor "Cyan"
	scoop status

    Write-Host "`nChecking updates for Chocolatey packages...`n" -ForegroundColor "Cyan"
    choco outdated

    Write-Host "`nChecking updates for MSYS2 packages...`n" -ForegroundColor "Cyan"
    & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$PWD' && pacman -Syup"

    Write-Host "`nChecking updates for Windows system...`n" -ForegroundColor "Cyan"
    gsudo Get-WindowsUpdate -Verbose
}

function wu {
    Write-Host "`nUpgrading WinGet packages...`n" -ForegroundColor "Cyan"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpgrading Scoop packages...`n" -ForegroundColor "Cyan"
    scoop update

    Write-Host "`nUpgrading Chocolatey packages...`n" -ForegroundColor "Cyan"
    gsudo choco upgrade all -y

    Write-Host "`nUpgrading Pip binary...`n" -ForegroundColor "Cyan"
    python.exe -m pip install --upgrade pip

    Write-Host "`nUpgrading Pipx packages...`n" -ForegroundColor "Cyan"
    pipx upgrade-all
    
    Write-Host "`nUpgrading MSYS2 packages...`n" -ForegroundColor "Cyan"
    & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$PWD' && pacman -Syu --noconfirm && paccache -r"

    Write-Host "`nUpgrading Windows system...`n" -ForegroundColor "Cyan"
    gsudo Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Verbose

    Remove-ItemSafely "$HOME\Desktop\*.lnk", "C:\Users\Public\Desktop\*.lnk"
}

# Repair
function Check-WindowsHealth {
    gsudo DISM /Online /Cleanup-Image /CheckHealth
    gsudo DISM /Online /Cleanup-Image /ScanHealth
}

function Repair-WindowsHealth {
    gsudo sfc /scannow
    gsudo DISM /Online /Cleanup-Image /RestoreHealth
}

# Network
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

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
