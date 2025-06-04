# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

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
            $icons = Get-ChildItem -Path $path -Filter "*.lnk" -ErrorAction SilentlyContinue
            
            foreach ($icon in $icons) {
                try {
                    bin $icon.FullName
                }
                catch {
                    Write-Host "Failed to delete: $($icon.Name)" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "Not found: $path." -ForegroundColor Red
        }
    }
}

function cleanDesktop {
    $desktopPath = "$Home\Desktop"

    Write-Host "Cleaning desktop..." -ForegroundColor Cyan

    if (Test-Path $desktopPath) {
        $items = Get-ChildItem -Path $desktopPath

        foreach ($item in $items) {
            try {
                bin $item.FullName
                Write-Host "Deleted: $($item.Name)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to delete: $($item.Name)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "Desktop folder does not exist." -ForegroundColor Red
    }
    
    Write-Host "Desktop cleaned." -ForegroundColor Green
}

function cleanDownloads {
    $downloadsPath = "$Home\Downloads"
    $excludeFolders = @("qBittorrent")

    Write-Host "Cleaning downloads..." -ForegroundColor Cyan

    if (Test-Path $downloadsPath) {
        $items = Get-ChildItem -Path $downloadsPath

        foreach ($item in $items) {
            if ($item.PSIsContainer -and $excludeFolders -contains $item.Name) {
                continue
            }

            try {
                bin $item.FullName
                Write-Host "Deleted: $($item.Name)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to delete: $($item.Name)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "Downloads folder does not exist." -ForegroundColor Red
    }

    Write-Host "Downloads cleaned." -ForegroundColor Green
}

function flushCache {
    Write-Host "Removing Windows cache..." -ForegroundColor Yellow
    
    if (Test-Path "$env:SystemRoot\Prefetch") {
        Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:SystemRoot\Temp") {
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$env:TEMP") {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Windows cache has been removed." -ForegroundColor Green
}

function unzip ($file) {
    $sevenZip = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $sevenZip)) {
        Write-Host "ERROR: 7-Zip not found at $sevenZip" -ForegroundColor Red
        return
    }
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    if (-not $fullFile) {
        Write-Host "ERROR: File '$file' not found in $pwd" -ForegroundColor Red
        return
    }
    Write-Host "Extracting $file to $pwd" -ForegroundColor Cyan
    & "$sevenZip" x "$fullFile" -o"$pwd" -y | Out-Null
}

# PSReadLine
$PSReadLineOptions = @{
    EditMode                      = 'Windows'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
        Command   = '#87CEEB'  # SkyBlue
        Parameter = '#98FB98'  # PaleGreen
        Operator  = '#FFB6C1'  # LightPink
        Variable  = '#DDA0DD'  # Plum
        String    = '#FFDAB9'  # PeachPuff
        Number    = '#B0E0E6'  # PowderBlue
        Type      = '#F0E68C'  # Khaki
        Comment   = '#D3D3D3'  # LightGray
        Keyword   = '#8367c7'  # Violet
        Error     = '#FF6347'  # Red
    }
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    BellStyle                     = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000

# Windows Terminal
function rt {
    wt --profile $env:WT_PROFILE_ID -d (Get-Location).Path
    exit
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
    try { winget source update } catch { Write-Host "winget source update failed." -ForegroundColor Red }
    try { winget upgrade --all --accept-package-agreements --accept-source-agreements } catch { Write-Host "winget upgrade failed." -ForegroundColor Red }
    
    Write-Host "Updating scoop packages..." -ForegroundColor "Cyan"
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        try { scoop update } catch { Write-Host "scoop update failed." -ForegroundColor Red }
    }
    else {
        Write-Host "scoop not found." -ForegroundColor Yellow
    }

    Write-Host "Updating pip binary..." -ForegroundColor "Cyan"
    if (Get-Command python.exe -ErrorAction SilentlyContinue) {
        try { python.exe -m pip install --upgrade pip } catch { Write-Host "pip upgrade failed." -ForegroundColor Red }
    }
    else {
        Write-Host "python.exe not found." -ForegroundColor Yellow
    }

    Write-Host "Updating pipx packages..." -ForegroundColor "Cyan"
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        try { pipx upgrade-all } catch { Write-Host "pipx upgrade-all failed." -ForegroundColor Red }
    }
    else {
        Write-Host "pipx not found." -ForegroundColor Yellow
    }

    Write-Host "Updating msys2 packages..." -ForegroundColor "Cyan"
    if (Get-Command ucrt -ErrorAction SilentlyContinue) {
        try { ucrt "pacman -Syu --noconfirm && paccache -r" } catch { Write-Host "msys2 update failed." -ForegroundColor Red }
    }
    else {
        Write-Host "ucrt function not found." -ForegroundColor Yellow
    }

    Write-Host "Updating apt packages..." -ForegroundColor "Cyan"
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        try { wsl sudo apt update } catch { Write-Host "apt update failed." -ForegroundColor Red }
        try { wsl sudo apt upgrade -y } catch { Write-Host "apt upgrade failed." -ForegroundColor Red }
        try { wsl sudo apt autoremove -y } catch { Write-Host "apt autoremove failed." -ForegroundColor Red }
    }
    else {
        Write-Host "wsl not found." -ForegroundColor Yellow
    }

    Write-Host "Updating wsl binary..." -ForegroundColor "Cyan"
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        try { wsl.exe --shutdown } catch { Write-Host "wsl.exe --shutdown failed." -ForegroundColor Red }
        try { wsl --update } catch { Write-Host "wsl --update failed." -ForegroundColor Red }
    }
    else {
        Write-Host "wsl.exe not found." -ForegroundColor Yellow
    }

    Write-Host "All updates completed." -ForegroundColor "Green"
    rmDesktopIcons
}

# Network
function flushDNS {
    Clear-DnsClientCache
    Write-Host "DNS cache has been removed." -ForegroundColor "Green"
}

function pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# File
function touch {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$names
    )
    foreach ($name in $names) {
        if (Test-Path $name) {
            (Get-Item $name).LastWriteTime = Get-Date
        }
        else {
            New-Item -ItemType "file" -Path . -Name $name | Out-Null
        }
    }
}

function mkcd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$dir
    )
    if (-not [string]::IsNullOrWhiteSpace($dir)) {
        if (-Not (Test-Path -Path $dir -PathType Container)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Set-Location $dir
    }
    else {
        Write-Host "ERROR: Directory name is required." -ForegroundColor Red
    }
}

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
    $musicFolder = [Environment]::GetFolderPath("MyMusic")
    $ytMusicFolder = Join-Path $musicFolder "YouTube Music"

    if (-not (Test-Path $ytMusicFolder)) {
        Write-Host "ERROR: '$ytMusicFolder' does not exist." -ForegroundColor Red
        return
    }

    if (-not $env:MUSIC_PLAYLIST_URL) {
        Write-Host "ERROR: MUSIC_PLAYLIST_URL environment variable is not set." -ForegroundColor Red
        return
    }

    Write-Host "Syncing music..." -ForegroundColor "Cyan"
    Set-Location $ytMusicFolder
    spotdl.exe $env:MUSIC_PLAYLIST_URL
    Write-Host "Music has been synced." -ForegroundColor "Cyan"
    Set-Location $currentDir
}

# su
function su {
    $currentDir = Get-Location
    if ($args.Count -gt 0) {
        $command = $args -join ' '
        Start-Process wt -Verb runAs -ArgumentList @("-d", "$currentDir", "-p", "PowerShell", "pwsh", "-NoExit", "-Command", "$command")
    }
    else {
        Start-Process wt -Verb runAs -ArgumentList @("-d", "$currentDir")
    }
}

# Trash
function bin {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Path
    )

    $trashDir = "C:\Users\Fahim\Trash"

    if (-not (Test-Path $trashDir)) {
        New-Item -Path $trashDir -ItemType Directory | Out-Null
    }

    foreach ($pattern in $Path) {
        $items = Get-Item -Path $pattern -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                $name = Split-Path -Path $item.FullName -Leaf
                $destination = Join-Path -Path $trashDir -ChildPath $name

                # Ensure unique filename if needed
                if (Test-Path $destination) {
                    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                    $destination = Join-Path -Path $trashDir -ChildPath "$timestamp`_$name"
                }

                Move-Item -Path $item.FullName -Destination $destination -Force
                Write-Host "Moved to Trash: $($item.Name)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "Failed to move: $($item.FullName)" -ForegroundColor Red
            }
        }
    }
}

function emptyBin {
    $trashDir = "C:\Users\Fahim\Trash"

    if (Test-Path $trashDir) {
        try {
            Get-ChildItem -Path $trashDir -Recurse -Force | Remove-Item -Force -Recurse
            Write-Host "Trash emptied." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to empty trash: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Trash folder does not exist: $trashDir" -ForegroundColor Red
    }
}

# Scoop Search
Invoke-Expression (&scoop-search --hook)