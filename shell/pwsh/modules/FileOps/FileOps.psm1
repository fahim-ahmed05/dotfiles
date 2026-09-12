function Clear-WindowsCache {
    [CmdletBinding()]
    param(
        [Alias('y')][switch]$Force,
        [string]$ConfigPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\configs\clear_windows_cache.json"
    )

    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Config file not found: $ConfigPath"
        return
    }

    $hasGum = [bool](Get-Command gum -ErrorAction SilentlyContinue)
    $isInteractive = [Environment]::UserInteractive -and $hasGum -and -not [Console]::IsInputRedirected

    if ($isInteractive -and -not $Force) {
        gum confirm --prompt.foreground="214" "Purge Windows caches and empty Recycle Bin?" 2>$null
        try {
            if ($Host.UI.RawUI.KeyAvailable) {
                while ($Host.UI.RawUI.KeyAvailable) { $null = [Console]::ReadKey($true) }
            }
            $Host.UI.RawUI.FlushInputBuffer()
        }
        catch {}
        if ($LASTEXITCODE -ne 0) { return }
    }

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $clearedPaths = 0
    $clearedCommands = 0

    foreach ($raw in $config.paths) {
        $path = [System.Environment]::ExpandEnvironmentVariables($raw)
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
            $clearedPaths++
        }
    }

    foreach ($cmd in $config.commands) {
        try {
            Invoke-Expression $cmd *>$null
            $clearedCommands++
        }
        catch {}
    }

    if ($hasGum -and -not [Console]::IsOutputRedirected) {
        $lines = @(
            "Windows Cache Purged",
            [string]::new([char]0x2500, 24),
            "  [+] Cleared temporary & cache directories ($clearedPaths locations)",
            "  [+] Cleaned package caches & emptied Recycle Bin"
        )
        $cardContent = $lines -join "`n"
        gum style --border normal --border-foreground 42 --padding "0 1" --margin "1 0" $cardContent
    }
    else {
        Write-Host "[+] Windows cache purged ($clearedPaths locations cleared)." -ForegroundColor Green
    }
}

function Clear-Folder {
    $defaultConfig = "$env:UserProfile\Git\dotfiles\shell\pwsh\configs\clear_folders_$computer.json"
    if ($args -notcontains '-ConfigPath') {
        & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Clear-Folder.ps1" -ConfigPath $defaultConfig @args
    }
    else {
        & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Clear-Folder.ps1" @args
    }
}

function Add-RemoveRegFiles {
    & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Add-RemoveRegFiles.ps1" @args
}

function Remove-DesktopIcons { Clear-Folder "$env:UserProfile\Desktop\*.lnk" "$env:PUBLIC\Desktop\*.lnk" -Force }


