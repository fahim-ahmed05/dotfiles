<#
.SYNOPSIS
    Moves folder contents to a Trash directory and/or empties the Trash.

.DESCRIPTION
    Reads source folders, exclusions, and the Trash path from a JSON config file.
    Paths in the config support environment variables (e.g. %USERPROFILE%).

.PARAMETER ConfigPath
    Path to the JSON config file.
    Defaults to: <script-dir>\..\configs\clear_folders.json

    Expected config shape:
        {
          "trashPath": "%USERPROFILE%\\Home\\Trash",
          "sources": [
            { "path": "%USERPROFILE%\\Desktop", "exclude": ["qBittorrent"] },
            { "path": "%USERPROFILE%\\Downloads" }
          ],
          "trashExclude": ["DoNotDelete"]
        }

    - "exclude" is optional per source; omit to move everything.
    - "exclude" matches by name and applies to both files and folders.

.PARAMETER Source
    Optional. Can be either:
    - A name/partial match against a config source path (e.g. "Downloads" matches "%USERPROFILE%\Downloads").
      The config's exclude list will be applied.
    - A direct path (rooted like "C:\Folder", relative like ".\subfolder", or "%ENV%\path").
      No exclusions are applied for direct paths.
    - "." to target the current directory.

.PARAMETER Empty
    Empties the Trash only. Cannot be combined with -All.

.PARAMETER All
    Cleans all sources then empties the Trash. Cannot be combined with -Empty.

.EXAMPLE
    .\Clear-Folder.ps1
    Cleans all sources defined in the config.

.EXAMPLE
    .\Clear-Folder.ps1 Downloads
    Cleans Downloads (matched from config).

.EXAMPLE
    .\Clear-Folder.ps1 .
    Cleans the current directory.

.EXAMPLE
    .\Clear-Folder.ps1 -Empty
    Only empties the Trash folder.

.EXAMPLE
    .\Clear-Folder.ps1 -All
    Cleans all sources then empties the Trash.

.EXAMPLE
    .\Clear-Folder.ps1 -ConfigPath "D:\configs\myclean.json"
    Cleans sources using a custom config file.
#>
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\configs\clear_folders.json"),
    [Parameter(Position=0)]
    [string]$Source = "",
    [switch]$Empty,
    [switch]$All
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

if (-not $Empty) {
    if ($Source) {
        # Treat as a direct path if it's rooted, starts with . or .., or contains % (env var)
        $isPath = [System.IO.Path]::IsPathRooted($Source) -or
                  $Source -match '^\.\.?[/\\]?' -or
                  $Source -match '%'
        if ($isPath) {
            $expandedSource = [System.Environment]::ExpandEnvironmentVariables($Source)
            $resolvedSource = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($expandedSource)
            Move-ToTrash -SourcePath $resolvedSource -Exclude @()
        } else {
            # Match by name against config sources
            $sources = $config.sources | Where-Object { $_.path -like "*$Source*" }
            if (-not $sources) {
                Write-Warning "No source matching '$Source' found in config."
            }
            foreach ($src in $sources) {
                $sourcePath = [System.Environment]::ExpandEnvironmentVariables($src.path)
                Move-ToTrash -SourcePath $sourcePath -Exclude $src.exclude
            }
        }
    } else {
        foreach ($src in $config.sources) {
            $sourcePath = [System.Environment]::ExpandEnvironmentVariables($src.path)
            Move-ToTrash -SourcePath $sourcePath -Exclude $src.exclude
        }
    }
}

if ($Empty -or $All) {
    Clear-Trash -Exclude $config.trashExclude
}
