function Clear-WindowsCache {
    $ConfigPath = "$env:UserProfile\Git\dotfiles\shell\powershell\configs\clear_windows_cache.json"

    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Config file not found: $ConfigPath"
        return
    }

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

    foreach ($raw in $config.paths) {
        $path = [System.Environment]::ExpandEnvironmentVariables($raw)
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    foreach ($cmd in $config.commands) {
        try { Invoke-Expression $cmd } catch {}
    }
}

function Remove-DesktopIcons {
    $paths = @(
        "$env:UserProfile\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item "$path\*.lnk" -Force -ErrorAction SilentlyContinue        
        }       
    }
}

