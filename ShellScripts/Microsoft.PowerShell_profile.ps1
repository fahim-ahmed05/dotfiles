# Module
Import-Module -Name Terminal-Icons

# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

# Alias
Set-Alias rm Remove-ItemSafely -Option AllScope
Set-Alias sudo gsudo -Option AllScope

function ytdlp {
    yt-dlp.exe --downloader aria2c @args
    
}

# Functions
function rmDesktopIcons {
    $desktopPaths = @(
        "$Home\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $desktopPaths) {
        if (Test-Path $path) {
            $lnkFiles = Get-ChildItem -Path $path -Filter "*.lnk" -ErrorAction SilentlyContinue
            if ($lnkFiles) {
                Remove-ItemSafely $lnkFiles.FullName
                Write-Host "$($lnkFiles.Count) shortcut(s) removed from: $path" -ForegroundColor Yellow
            }
            else {
                Write-Host "No shortcuts found in: $path" -ForegroundColor Green
            }
        }
        else {
            Write-Host "The path does not exist: $path" -ForegroundColor Red
        }
    }
}

function cleanDownloads {
    $downloadsPath = "$Home\Downloads"
    $excludeFolders = @("qBittorrent")

    if (Test-Path $downloadsPath) {
        $items = Get-ChildItem -Path $downloadsPath

        foreach ($item in $items) {
            if ($item.PSIsContainer -and $excludeFolders -contains $item.Name) {
                continue
            }

            try {
                Remove-ItemSafely $item.FullName
                Write-Host "Deleted: $($item.FullName)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to delete: $($item.FullName)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "Downloads folder does not exist." -ForegroundColor Red
    }
}

function flushCache {
    Write-Host "Removing Windows cache..." -ForegroundColor Yellow
    
    if (Test-Path "$env:SystemRoot\Prefetch") {
        Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:SystemRoot\Temp") {
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:TEMP") {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Windows cache has been removed." -ForegroundColor Green
}

# PowerShell
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Green'
    String    = 'DarkCyan'
}

# Terminal
function rt { 
    $currentDir = Get-Location
    exit & wt -d $currentDir
}

function reloadProfile { 
    . $PROFILE
}

# Winget
function ws {
    winget search @args 
}

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5
    rmDesktopIcons
}

function wu {
    Write-Host "Updating winget packages..." -ForegroundColor "Cyan"
    winget upgrade --all --accept-package-agreements --accept-source-agreements
    
    Write-Host "Updating scoop packages..." -ForegroundColor "Cyan"
    scoop update

    Write-Host "Updating pip binary..." -ForegroundColor "Cyan"
    python.exe -m pip install --upgrade pip

    Write-Host "Updating pipx packages..." -ForegroundColor "Cyan"
    pipx upgrade-all

    Write-Host "Updating msys2 packages..." -ForegroundColor "Cyan"
    ucrt "pacman -Syu --noconfirm && paccache -r"

    Write-Host "Updating apt packages..." -ForegroundColor "Cyan"
    wsl sudo apt update
    wsl sudo apt upgrade -y
    wsl sudo apt autoremove -y

    Write-Host "Updating wsl binary..." -ForegroundColor "Cyan"
    wsl.exe --shutdown
    wsl --update

    Write-Host "All updates completed." -ForegroundColor "Green"
    rmDesktopIcons
}

# Network
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS cache has been removed." -ForegroundColor "Green"
}

function pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

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

# UCRT64
function ucrt {
    param (
        [string]$Command = $null
    )

    $currentDir = Get-Location

    if ($Command) {
        & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$currentDir' && $Command"
    }
    else {
        & "C:\msys64\usr\bin\bash.exe" --login -c "export MSYSTEM=UCRT64 && cd '$currentDir' && exec bash"
    }
}

#Sync Music
function syncMusic {
    $currentDir = Get-Location
    Write-Host "Syncing music..." -ForegroundColor "Cyan"
    Set-Location "$HOME\Music\Songs"
    spotdl.exe $env:MUSIC_PLAYLIST_URL
    Write-Host "Music has been synced." -ForegroundColor "Cyan"
    Set-Location $currentDir
}