function bin {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Path
    )

    $trashRoot = "C:\Users\Fahim\Trash"
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $trashDir = Join-Path $trashRoot $timestamp

    if (-not (Test-Path $trashDir)) {
        New-Item -Path $trashDir -ItemType Directory | Out-Null
    }

    foreach ($pattern in $Path) {
        $items = Get-Item -Path $pattern -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                Move-Item -Path $item.FullName -Destination $trashDir -Force
                Write-Host "🗑️ Moved to Trash: $($item.Name)" -ForegroundColor Yellow
            }
            catch {
                Write-Host "❌ Failed to move: $($item.FullName)" -ForegroundColor Red
            }
        }
    }
}

function rmDesktopIcons {
    $desktopPaths = @(
        "$HOME\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $desktopPaths) {
        if (Test-Path $path) {
            $icons = Get-ChildItem -Path $path -Filter "*.lnk" -ErrorAction SilentlyContinue
            foreach ($icon in $icons) {
                bin $icon.FullName
            }
        }
        else {
            Write-Host "📂 Not found: $path" -ForegroundColor DarkGray
        }
    }
}

function cleanDesktop {
    $desktopPath = "$HOME\Desktop"

    Write-Host "🧼 Cleaning desktop..." -ForegroundColor Cyan

    if (Test-Path $desktopPath) {
        $items = Get-ChildItem -Path $desktopPath
        foreach ($item in $items) {
            bin $item.FullName
        }
        Write-Host "✅ Desktop cleaned." -ForegroundColor Green
    }
    else {
        Write-Host "🚫 Desktop folder does not exist." -ForegroundColor Red
    }
}

function cleanDownloads {
    $downloadsPath = "$HOME\Downloads"
    $excludeFolders = @("qBittorrent")

    Write-Host "🧼 Cleaning Downloads..." -ForegroundColor Cyan

    if (Test-Path $downloadsPath) {
        $items = Get-ChildItem -Path $downloadsPath
        foreach ($item in $items) {
            if ($item.PSIsContainer -and $excludeFolders -contains $item.Name) {
                continue
            }
            bin $item.FullName
        }
        Write-Host "✅ Downloads cleaned." -ForegroundColor Green
    }
    else {
        Write-Host "🚫 Downloads folder does not exist." -ForegroundColor Red
    }
}

function emptyBin {
    $trashDir = "C:\Users\Fahim\Trash"

    if (Test-Path $trashDir) {
        try {
            Get-ChildItem -Path $trashDir -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Stop
            Write-Host "🧹 Trash emptied." -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to empty trash: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "🚫 Trash folder does not exist: $trashDir" -ForegroundColor Red
    }
}

function flushCache {
    Write-Host "🧹 Removing Windows cache..." -ForegroundColor Yellow

    $paths = @(
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\Temp",
        "$env:TEMP"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    Write-Host "✅ Windows cache removed." -ForegroundColor Green
}

function flushDNS {
    Clear-DnsClientCache
    Write-Host "✅ DNS cache removed." -ForegroundColor Green
}
