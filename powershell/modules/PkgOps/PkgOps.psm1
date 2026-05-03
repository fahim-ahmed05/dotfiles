Set-Alias gitpkg "$env:UserProfile\gitpkg\gitpkg@main-e90b9fb1\gitpkg.ps1"

function Search-Packages {
    $query = $args -join ' '
    $scoopQuery = ($query -replace '\s+', '-')

    Write-Host "`nSearching winget packages...`n" -ForegroundColor Cyan
    winget search $query
    
    Write-Host "`nSearching scoop packages..." -ForegroundColor Cyan
    & "$env:UserProfile\Git\fast-scoop-search\Scoop-Search.ps1" $scoopQuery
}

function Update-AllPackages {
    Write-Host "`nUpdating winget packages...`n" -ForegroundColor Cyan
    winget source update
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating winget...`n" -ForegroundColor Cyan
    winget upgrade winget --accept-package-agreements --accept-source-agreements

    Write-Host "`nUpdating scoop packages...`n" -ForegroundColor Cyan
    scoop update
    scoop update -a
    scoop status

    Write-Host "`nUpdating uv packages...`n" -ForegroundColor Cyan
    uv tool upgrade --all

    Write-Host "`nUpdating gitpkg packages...`n" -ForegroundColor Cyan
    gitpkg pull
    
    Write-Host "`nRemoving desktop icons...`n" -ForegroundColor Cyan
    Remove-DesktopIcons
    Write-Host "Done.`n" -ForegroundColor Green
}

function Install-Packages {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Packages
    )

    foreach ($pkg in $Packages) {
        $digitCount = ([regex]::Matches($pkg, '\d')).Count

        if ($digitCount -gt 1) {
            Write-Host "`nInstalling $pkg via winget...`n" -ForegroundColor Cyan
            winget install "$pkg" --source msstore --accept-package-agreements --accept-source-agreements
        }

        elseif ($pkg -match '\.') {
            Write-Host "`nInstalling $pkg via winget...`n" -ForegroundColor Cyan
            winget install "$pkg" --source winget --accept-package-agreements --accept-source-agreements
        }

        else {
            Write-Host "`nInstalling $pkg via scoop...`n" -ForegroundColor Cyan
            scoop install "$pkg"
        }
    }

    Remove-DesktopIcons
}


