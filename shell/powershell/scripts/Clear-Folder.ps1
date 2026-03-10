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
    Optional. Behaviour mirrors rm semantics:
    - Omit              : clean all sources defined in the config (with their excludes).
    - "Downloads"       : partial match against config sources, applies config excludes.
    - "."               : move the current folder itself to Trash.
    - "*"               : move contents of the current folder to Trash.
    - "C:\Folder"       : move that folder itself to Trash.
    - "C:\Folder\*"     : move contents of that folder to Trash.
    - "%ENV%\path"      : env vars are expanded; same . / * rules apply.

.PARAMETER Empty
    Empties the Trash only. Cannot be combined with -All.

.PARAMETER All
    Cleans all sources then empties the Trash. Cannot be combined with -Empty.

.EXAMPLE
    .\Clear-Folder.ps1
    Cleans all sources defined in the config.

.EXAMPLE
    .\Clear-Folder.ps1 Downloads
    Cleans Downloads (matched from config, excludes applied).

.EXAMPLE
    .\Clear-Folder.ps1 .
    Moves the current folder itself to Trash.

.EXAMPLE
    .\Clear-Folder.ps1 *
    Moves the contents of the current folder to Trash.

.EXAMPLE
    .\Clear-Folder.ps1 "C:\Foo\*"
    Moves the contents of C:\Foo to Trash.

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

function Assert-SafePath {
    param([string]$ResolvedPath)
    $resolvedHome = [System.IO.Path]::GetFullPath($HOME)
    if ($ResolvedPath -eq $resolvedHome) {
        Write-Warning "Refusing to move the user home folder ($ResolvedPath). Specify a subfolder instead."
        return $false
    }
    return $true
}

# Moves the folder itself into Trash
function Move-FolderToTrash {
    param([string]$SourcePath)

    $resolved = [System.IO.Path]::GetFullPath($SourcePath)

    if (-not (Test-Path $resolved)) {
        Write-Warning "Path not found: $resolved"
        return
    }
    if (-not (Assert-SafePath $resolved)) { return }

    $destination = Join-Path $trashPath (Split-Path $resolved -Leaf)
    if (Test-Path $destination) {
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $destination = "${destination}_$timestamp"
    }

    try {
        Move-Item -Path $resolved -Destination $destination -Force -ErrorAction Stop
        Write-Host "Moved: $resolved -> $destination" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed: $resolved. Error: $($_.Exception.Message)"
    }
}

# Moves the contents of a folder into Trash
function Move-ToTrash {
    param([string]$SourcePath, [string[]]$Exclude)

    $resolved = [System.IO.Path]::GetFullPath($SourcePath)

    if (-not (Test-Path $resolved)) {
        Write-Warning "Source path not found: $resolved"
        return
    }
    if (-not (Assert-SafePath $resolved)) { return }

    # Exclude matches both files and folders by name
    $items = Get-ChildItem -Path $resolved -Force

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

    Write-Host "`n$resolved cleaned. Kept: $($Exclude -join ', ')" -ForegroundColor Cyan
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
                  $Source -match '^\.' -or
                  $Source -match '%' -or
                  $Source -eq '*'
        if ($isPath) {
            # Trailing \* or bare * = move contents; everything else = move the folder itself
            if ($Source -eq '*') {
                # * = contents of current directory
                Move-ToTrash -SourcePath (Get-Location).Path -Exclude @()
            } elseif ($Source -match '[/\\]\*$' -or $Source.EndsWith('*')) {
                # path\* or path/* = contents of that folder
                $base = [System.Environment]::ExpandEnvironmentVariables($Source -replace '[/\\]?\*$', '')
                $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($base)
                Move-ToTrash -SourcePath $resolved -Exclude @()
            } else {
                # bare path or . = move the folder itself
                $expanded = [System.Environment]::ExpandEnvironmentVariables($Source)
                $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($expanded)
                Move-FolderToTrash -SourcePath $resolved
            }
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
