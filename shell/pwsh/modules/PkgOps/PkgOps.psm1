function Search-Packages {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )

    $wingetQuery = $Query -join ' '
    $scoopQuery = $Query -join '-'

    Write-Host "`nSearching winget packages for '$wingetQuery'...`n" -ForegroundColor Cyan
    winget search "$wingetQuery"

    Write-Host "`nSearching scoop packages for '$scoopQuery'...`n" -ForegroundColor Cyan

    $scoopSearchPath = "$env:UserProfile\Git\fast-scoop-search\Scoop-Search.ps1"

    if (Test-Path $scoopSearchPath) {
        & $scoopSearchPath "$scoopQuery"
    }
    else {
        Write-Host "Fast search script missing. Falling back to native scoop search..." -ForegroundColor Yellow
        scoop search "$scoopQuery"
    }
}

function Update-AllPackages {
    Write-Host "`nChecking for pwsh update...`n" -ForegroundColor Cyan
    scoop update
    $pwshUpdate = scoop status | Select-String "^\s*pwsh:"

    if ($pwshUpdate) {
        Write-Host "Update found for pwsh. Restarting terminal to apply update..." -ForegroundColor Yellow
        $currentPath = (Get-Location).Path
        $encodedPath = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($currentPath))
        
        $scriptTemplate = '
                            scoop update pwsh
                            $path = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String("{0}"))
                            if ($env:WT_SESSION) {
                                wt --profile "$env:WT_PROFILE_ID" -d "$path" pwsh -NoExit -Command Update-AllPackages
                            } elseif ($env:ALACRITTY_LOG) {
                                Start-Process alacritty -ArgumentList "--working-directory `"$path`" -e pwsh -NoExit -Command Update-AllPackages"
                            } else {
                                Write-Warning "Terminal not recognized. Update applied but please restart your terminal manually."
                                Start-Sleep -Seconds 5
                            }
                            '
        $script = $scriptTemplate -f $encodedPath
        $encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))
        
        Start-Process powershell -ArgumentList "-NoProfile", "-EncodedCommand", $encodedScript
        exit
    }

    Write-Host "`nUpdating winget sources and binary...`n" -ForegroundColor Cyan
    winget source update
    winget upgrade Microsoft.AppInstaller --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating winget packages...`n" -ForegroundColor Cyan
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating scoop packages...`n" -ForegroundColor Cyan
    scoop update -a; scoop status

    Write-Host "`nUpdating uv packages...`n" -ForegroundColor Cyan
    uv tool upgrade --all

    Write-Host "`nUpdating git repos...`n" -ForegroundColor Cyan

    $gitScriptPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Pull-GitRepos.ps1"
    $gitConfigPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\configs\git_repos_$computer.json"

    if ((Test-Path $gitScriptPath) -and (Test-Path $gitConfigPath)) {
        & $gitScriptPath -ConfigPath $gitConfigPath
    }
    else {
        Write-Host "Git pull script or config for '$computer' not found. Skipping repository updates..." -ForegroundColor Yellow
    }

    Write-Host "`nRemoving desktop icons...`n" -ForegroundColor Cyan
    Remove-DesktopIcons
}

function Install-Packages {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Packages
    )

    foreach ($pkg in $Packages) {
        # MS Store ID: Exactly 12 characters, mix of letters and numbers
        if ($pkg -match '^(?=.*\d)[A-Za-z0-9]{12}$') {
            Write-Host "`nInstalling $pkg via winget (MS Store)...`n" -ForegroundColor Cyan
            winget install -e --id "$pkg" --source msstore --accept-package-agreements --accept-source-agreements
        }

        # Winget ID: Contains a dot with characters on both sides (e.g., Publisher.App)
        elseif ($pkg -match '^[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$') {
            Write-Host "`nInstalling $pkg via winget...`n" -ForegroundColor Cyan
            winget install -e --id "$pkg" --source winget --accept-package-agreements --accept-source-agreements
        }

        else {
            Write-Host "`nInstalling $pkg via scoop...`n" -ForegroundColor Cyan
            scoop install "$pkg"
        }
    }

    Remove-DesktopIcons
}

function Uninstall-Packages {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Packages
    )

    foreach ($pkg in $Packages) {
        if ($pkg -match '^(?=.*\d)[A-Za-z0-9]{12}$') {
            Write-Host "`nUninstalling $pkg via winget (MS Store)...`n" -ForegroundColor Yellow
            winget uninstall -e --id "$pkg"
        }

        elseif ($pkg -match '^[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$') {
            Write-Host "`nUninstalling $pkg via winget...`n" -ForegroundColor Yellow
            winget uninstall -e --id "$pkg"
        }

        else {
            Write-Host "`nUninstalling $pkg via scoop...`n" -ForegroundColor Yellow
            scoop uninstall "$pkg"
        }
    }
}
