function Clear-WindowsCache {
    $ConfigPath = "$env:UserProfile\Git\dotfiles\powershell\configs\clear_windows_cache.json"

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

function Clear-Folder {
    $computer = $env:COMPUTERNAME.ToLowerInvariant()
    $config = Join-Path $env:UserProfile "Git\dotfiles\powershell\configs\clear_folders_$computer.json"
    $script = Join-Path $env:UserProfile "Git\dotfiles\powershell\scripts\Clear-Folder.ps1"

    & $script -ConfigPath $config @args
}

function Remove-DesktopIcons { Clear-Folder "$env:UserProfile\Desktop\*.lnk" "$env:PUBLIC\Desktop\*.lnk" }


