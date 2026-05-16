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
    & "$env:UserProfile\Git\dotfiles\powershell\scripts\Clear-Folder.ps1" -ConfigPath "$env:UserProfile\Git\dotfiles\powershell\configs\clear_folders_$computer.json" @args
}

function Add-RemoveRegFiles {
    & "$env:UserProfile\Git\dotfiles\powershell\scripts\Add-RemoveRegFiles.ps1" -Config "$env:UserProfile\Git\dotfiles\powershell\configs\reg_files.json" @args
}

function Remove-DesktopIcons { Clear-Folder "$env:UserProfile\Desktop\*.lnk" "$env:PUBLIC\Desktop\*.lnk" }


