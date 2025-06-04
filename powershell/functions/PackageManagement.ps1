function ws {
    winget search @args
}

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5

    if (Get-Command rmDesktopIcons -ErrorAction SilentlyContinue) {
        rmDesktopIcons
    }
}

function wu {
    Write-Host "📦 Updating winget packages..." -ForegroundColor Cyan
    try {
        winget source update
        winget upgrade --all --accept-package-agreements --accept-source-agreements
    }
    catch {
        Write-Host "❌ Winget update failed." -ForegroundColor Red
    }

    Write-Host "📦 Updating scoop packages..." -ForegroundColor Cyan
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        try {
            scoop update
            scoop cleanup *
        }
        catch {
            Write-Host "❌ Scoop update or cleanup failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ Scoop not installed." -ForegroundColor Yellow
    }

    Write-Host "🐍 Updating pip..." -ForegroundColor Cyan
    if (Get-Command python.exe -ErrorAction SilentlyContinue) {
        try {
            python.exe -m pip install --upgrade pip
        }
        catch {
            Write-Host "❌ pip upgrade failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ Python not installed." -ForegroundColor Yellow
    }

    Write-Host "📦 Updating pipx packages..." -ForegroundColor Cyan
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        try {
            pipx upgrade-all
        }
        catch {
            Write-Host "❌ pipx upgrade failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ pipx not installed." -ForegroundColor Yellow
    }

    if (Get-Command rmDesktopIcons -ErrorAction SilentlyContinue) {
        rmDesktopIcons
    }
}
