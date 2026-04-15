<#
.SYNOPSIS
    Moves folder contents/files to a Trash directory and/or empties the Trash.

.DESCRIPTION
    Reads source folders, exclusions, and the Trash path from a JSON config file.
    Paths in the config support environment variables (e.g. %USERPROFILE%).

.PARAMETER ConfigPath
    Path to the JSON config file.
    Defaults to: <script-dir>\..\configs\clear_folders.json

.PARAMETER Source
    Optional. Array of paths or config aliases. Behaviour mirrors rm semantics:
    - Omit              : clean all sources defined in the config (with their excludes).
    - "Downloads"       : partial match against config sources, applies config excludes.
    - "."               : move the current folder itself to Trash.
    - "*"               : move contents of the current folder to Trash.
    - "C:\Folder"       : move that folder itself to Trash.
    - "C:\Folder\*"     : move contents of that folder to Trash.
    - "C:\Folder\*.lnk" : move only .lnk files from that folder to Trash.
    - "%ENV%\path"      : env vars are expanded; same rules apply.

.PARAMETER Empty
    Empties the Trash only. Cannot be combined with -All.

.PARAMETER All
    Cleans all sources then empties the Trash. Cannot be combined with -Empty.
#>
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\configs\clear_folders.json"),
    
    # ValueFromRemainingArguments allows space-separated paths without commas
    [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Source = @(),
    
    [switch]$Empty,
    [switch]$All
)

# 1. Load Configuration
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Warning "Config file not found: $ConfigPath"
    return
}
$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$trashPath = [System.Environment]::ExpandEnvironmentVariables($config.trashPath)

if (-not (Test-Path -LiteralPath $trashPath)) {
    New-Item -ItemType Directory -Path $trashPath | Out-Null
}

# 2. Helper Functions
function Assert-SafePath {
    param([string]$ResolvedPath)
    $resolvedHome = [System.IO.Path]::GetFullPath($HOME)
    if ($ResolvedPath -eq $resolvedHome) {
        Write-Warning "Refusing to move the user home folder ($ResolvedPath)."
        return $false
    }
    return $true
}

function Process-ItemToTrash {
    param(
        [System.IO.FileSystemInfo]$Item,
        [string[]]$Exclude
    )

    # Check for exclusions (supports exact names and wildcards like *.lnk)
    $isExcluded = $false
    foreach ($ex in $Exclude) {
        if ($Item.Name -like $ex) {
            $isExcluded = $true
            break
        }
    }
    
    if ($isExcluded) {
        Write-Host "Skipped (Excluded): $($Item.FullName)" -ForegroundColor DarkGray
        return
    }

    if (-not (Assert-SafePath $Item.FullName)) { return }

    $dest = Join-Path $trashPath $Item.Name

    # Collision Handling: Preserve extension on files
    if (Test-Path -LiteralPath $dest) {
        $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
        if ($Item -is [System.IO.FileInfo]) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Item.Name)
            $ext = [System.IO.Path]::GetExtension($Item.Name)
            $dest = Join-Path $trashPath "${baseName}_${timestamp}${ext}"
        } else {
            $dest = Join-Path $trashPath "$($Item.Name)_$timestamp"
        }
        
        # Failsafe for rapid loop collisions
        $counter = 1
        while (Test-Path -LiteralPath $dest) {
            if ($Item -is [System.IO.FileInfo]) {
                $dest = Join-Path $trashPath "${baseName}_${timestamp}_${counter}${ext}"
            } else {
                $dest = Join-Path $trashPath "$($Item.Name)_${timestamp}_${counter}"
            }
            $counter++
        }
    }

    try {
        Move-Item -LiteralPath $Item.FullName -Destination $dest -Force -ErrorAction Stop
        Write-Host "Moved: $($Item.FullName) -> $dest" -ForegroundColor Green
    } catch {
        Write-Warning "Failed: $($Item.FullName). Error: $($_.Exception.Message)"
    }
}

function Clear-Trash {
    param([string[]]$Exclude)
    $items = Get-ChildItem -LiteralPath $trashPath -Force

    foreach ($item in $items) {
        # Check for exclusions (supports exact names and wildcards)
        $isExcluded = $false
        foreach ($ex in $Exclude) {
            if ($item.Name -like $ex) {
                $isExcluded = $true
                break
            }
        }

        if ($isExcluded) {
            Write-Host "Skipped: $($item.FullName)" -ForegroundColor DarkGray
            continue
        }
        
        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
            Write-Host "Deleted: $($item.FullName)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
        }
    }
    Write-Host "`nTrash emptied." -ForegroundColor Cyan
}

# 3. Main Logic execution
if (-not $Empty) {
    if ($Source.Count -gt 0) {
        foreach ($s in $Source) {
            # Heuristic to check if input is a literal file path/wildcard or a config alias
            $isPathLike = [System.IO.Path]::IsPathRooted($s) -or $s -match '^\.' -or $s -match '%' -or $s -match '\*' -or $s -match '[\\/]'
            
            if (-not $isPathLike) {
                $matchedSources = $config.sources | Where-Object { $_.path -like "*$s*" }
                if ($matchedSources) {
                    foreach ($src in $matchedSources) {
                        $expanded = [System.Environment]::ExpandEnvironmentVariables($src.path)
                        if (Test-Path -LiteralPath $expanded) {
                            $items = Get-ChildItem -LiteralPath $expanded -Force
                            foreach ($item in $items) {
                                Process-ItemToTrash -Item $item -Exclude $src.exclude
                            }
                        }
                    }
                    continue
                }
            }

            # Handle as direct path, wildcard, or specific file
            $expanded = [System.Environment]::ExpandEnvironmentVariables($s)
            try {
                # Get-Item natively handles *.lnk, \*, and explicit files/folders.
                $items = Get-Item -Path $expanded -Force -ErrorAction Stop
                foreach ($item in $items) {
                    Process-ItemToTrash -Item $item -Exclude @()
                }
            } catch {
                Write-Warning "Path not found or invalid: $expanded"
            }
        }
    } else {
        # No source specified, clean all from config
        foreach ($src in $config.sources) {
            $expanded = [System.Environment]::ExpandEnvironmentVariables($src.path)
            if (Test-Path -LiteralPath $expanded) {
                $items = Get-ChildItem -LiteralPath $expanded -Force
                foreach ($item in $items) {
                    Process-ItemToTrash -Item $item -Exclude $src.exclude
                }
            }
        }
    }
}

# Empty Trash if requested
if ($Empty -or $All) {
    Clear-Trash -Exclude $config.trashExclude
}