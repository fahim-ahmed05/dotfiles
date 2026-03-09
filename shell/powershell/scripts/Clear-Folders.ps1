param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\configs\clear_folders.json"),
    [ValidateSet("Clean", "Empty", "All")]
    [string]$Action = "All",
    [string]$Source = ""
)

$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

$trashPath = [System.Environment]::ExpandEnvironmentVariables($config.trashPath)

if (-not (Test-Path $trashPath)) {
    New-Item -ItemType Directory -Path $trashPath | Out-Null
}

function Move-ToTrash {
    param([string]$SourcePath, [string[]]$Exclude)

    if (-not (Test-Path $SourcePath)) {
        Write-Warning "Source path not found: $SourcePath"
        return
    }

    # Exclude matches both files and folders by name
    $items = Get-ChildItem -Path $SourcePath -Force

    foreach ($item in $items) {
        if ($Exclude -notcontains $item.Name) {
            try {
                $destination = Join-Path $trashPath $item.Name

                if (Test-Path $destination) {
                    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
                    $destination = "${destination}_$timestamp"
                }

                Move-Item -Path $item.FullName -Destination $destination -Force -ErrorAction Stop
                Write-Host "Moved: $($item.FullName) -> $destination" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "Skipped: $($item.FullName)" -ForegroundColor Yellow
        }
    }

    Write-Host "`n$SourcePath cleaned. Kept: $($Exclude -join ', ')" -ForegroundColor Cyan
}

function Clear-Trash {
    param([string[]]$Exclude)

    $items = Get-ChildItem -Path $trashPath -Force

    foreach ($item in $items) {
        if ($Exclude -notcontains $item.Name) {
            try {
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                Write-Host "Deleted: $($item.FullName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "Skipped: $($item.FullName)" -ForegroundColor Yellow
        }
    }

    Write-Host "`nTrash emptied. Kept: $($Exclude -join ', ')" -ForegroundColor Cyan
}

if ($Action -in @("Clean", "All")) {
    $sources = $config.sources
    if ($Source) {
        $sources = $sources | Where-Object { $_.path -like "*$Source*" }
        if (-not $sources) {
            Write-Warning "No source matching '$Source' found in config."
        }
    }
    foreach ($src in $sources) {
        $sourcePath = [System.Environment]::ExpandEnvironmentVariables($src.path)
        Move-ToTrash -SourcePath $sourcePath -Exclude $src.exclude
    }
}

if ($Action -in @("Empty", "All")) {
    Clear-Trash -Exclude $config.trashExclude
}
