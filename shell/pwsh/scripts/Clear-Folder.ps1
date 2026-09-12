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

.PARAMETER EmptyTrash
    Empties the Trash only. Cannot be combined with -All.

.PARAMETER All
    Cleans all sources then empties the Trash. Cannot be combined with -EmptyTrash.

.PARAMETER RemoveEmptyDirs
    Optional. If specified, ONLY recursively searches the provided sources for empty folders and moves them to the Trash. Normal file clearing is skipped.

.PARAMETER Force
    Bypasses interactive menus and confirmation prompts.
#>
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "..\configs\clear_folders.json"),
    
    [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
    [string[]]$Source = @(),
    
    [switch]$EmptyTrash,
    [switch]$All,
    [switch]$RemoveEmptyDirs,
    [Alias('y')][switch]$Force
)

function Clear-ConsoleInput {
    try {
        if ($Host.UI.RawUI.KeyAvailable) {
            while ($Host.UI.RawUI.KeyAvailable) { $null = [Console]::ReadKey($true) }
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }
    catch {}
}

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

$hasGum = $null -ne (Get-Command gum -ErrorAction SilentlyContinue)
$isInteractive = $hasGum

# Interactive Action Menu if no arguments passed
if ($isInteractive -and $Source.Count -eq 0 -and -not $EmptyTrash -and -not $All -and -not $RemoveEmptyDirs -and -not $Force) {
    $menuOptions = @(
        "Clean configured sources (Desktop, Downloads)",
        "Clean Desktop only",
        "Clean Downloads only",
        "Empty Trash permanently",
        "Clean all sources and empty Trash",
        "Remove empty subdirectories"
    )
    $menu = gum choose --header="Select Clear-Folder Action:" --header.foreground="39" --cursor="> " --cursor.foreground="39" $menuOptions
    Clear-ConsoleInput
    if ($LASTEXITCODE -ne 0 -or -not $menu) {
        Write-Host "`e[1A`e[2K`r" -NoNewline
        return
    }

    switch -Wildcard ($menu) {
        "*Desktop, Downloads*" { } # default configured sources
        "*Desktop only*"       { $Source = @("Desktop") }
        "*Downloads only*"     { $Source = @("Downloads") }
        "*Empty Trash perm*"   { $EmptyTrash = $true }
        "*Clean all sources*"  { $All = $true }
        "*Remove empty sub*"   { $RemoveEmptyDirs = $true }
    }
}

# Confirmation before permanently emptying Trash
if (($EmptyTrash -or $All) -and $isInteractive -and -not $Force) {
    gum confirm --prompt.foreground="214" "Permanently delete all items in Trash?"
    Clear-ConsoleInput
    if ($LASTEXITCODE -ne 0) { return }
}

# Tracking metrics
$script:movedCount = 0
$script:deletedCount = 0
$script:skippedCount = 0

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

function Move-ItemToTrash {
    param(
        [System.IO.FileSystemInfo]$Item,
        [string[]]$Exclude
    )

    $isExcluded = $false
    foreach ($ex in $Exclude) {
        if ($Item.Name -like $ex) {
            $isExcluded = $true
            break
        }
    }
    
    if ($isExcluded) {
        $script:skippedCount++
        if (-not $isInteractive) {
            Write-Host "Skipped (Excluded): $($Item.FullName)" -ForegroundColor DarkGray
        }
        return
    }

    if (-not (Assert-SafePath $Item.FullName)) { return }

    $dest = Join-Path $trashPath $Item.Name

    if (Test-Path -LiteralPath $dest) {
        $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
        if ($Item -is [System.IO.FileInfo]) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Item.Name)
            $ext = [System.IO.Path]::GetExtension($Item.Name)
            $dest = Join-Path $trashPath "${baseName}_${timestamp}${ext}"
        }
        else {
            $dest = Join-Path $trashPath "$($Item.Name)_$timestamp"
        }
        
        $counter = 1
        while (Test-Path -LiteralPath $dest) {
            if ($Item -is [System.IO.FileInfo]) {
                $dest = Join-Path $trashPath "${baseName}_${timestamp}_${counter}${ext}"
            }
            else {
                $dest = Join-Path $trashPath "$($Item.Name)_${timestamp}_${counter}"
            }
            $counter++
        }
    }

    try {
        Move-Item -LiteralPath $Item.FullName -Destination $dest -Force -ErrorAction Stop
        $script:movedCount++
        if (-not $isInteractive) {
            Write-Host "Moved: $($Item.FullName) -> $dest" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Failed: $($Item.FullName). Error: $($_.Exception.Message)"
    }
}

function Clear-Trash {
    param([string[]]$Exclude)
    $items = Get-ChildItem -LiteralPath $trashPath -Force

    foreach ($item in $items) {
        $isExcluded = $false
        foreach ($ex in $Exclude) {
            if ($item.Name -like $ex) {
                $isExcluded = $true
                break
            }
        }

        if ($isExcluded) {
            $script:skippedCount++
            if (-not $isInteractive) {
                Write-Host "Skipped: $($item.FullName)" -ForegroundColor DarkGray
            }
            continue
        }
        
        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
            $script:deletedCount++
            if (-not $isInteractive) {
                Write-Host "Deleted: $($item.FullName)" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
        }
    }
    if (-not $isInteractive) {
        Write-Host "`nTrash emptied." -ForegroundColor Cyan
    }
}

function Remove-EmptyDirectories {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return }
    
    # Bottom-up approach
    $dirs = Get-ChildItem -LiteralPath $Path -Recurse -Directory -Force | Sort-Object -Property @{Expression = { $_.FullName.Length }; Descending = $true }
    foreach ($dir in $dirs) {
        $items = Get-ChildItem -LiteralPath $dir.FullName -Force
        if ($items.Count -eq 0) {
            Move-ItemToTrash -Item $dir -Exclude @()
        }
    }
}

# 3. Main Logic execution
$dirsToClean = @()
if (-not $EmptyTrash) {
    if ($Source.Count -gt 0) {
        foreach ($s in $Source) {
            $isPathLike = [System.IO.Path]::IsPathRooted($s) -or $s -match '^\.' -or $s -match '%' -or $s -match '\*' -or $s -match '[\\/]'
            
            if (-not $isPathLike) {
                $matchedSources = $config.sources | Where-Object { $_.path -like "*$s*" }
                if ($matchedSources) {
                    foreach ($src in $matchedSources) {
                        $expanded = [System.Environment]::ExpandEnvironmentVariables($src.path)
                        if (Test-Path -LiteralPath $expanded) {
                            if (-not $RemoveEmptyDirs) {
                                $items = Get-ChildItem -LiteralPath $expanded -Force
                                foreach ($item in $items) {
                                    Move-ItemToTrash -Item $item -Exclude $src.exclude
                                }
                            }
                            $dirsToClean += $expanded
                        }
                    }
                    continue
                }
            }

            $expanded = [System.Environment]::ExpandEnvironmentVariables($s)
            try {
                if (-not $RemoveEmptyDirs) {
                    $items = Get-Item -Path $expanded -Force -ErrorAction Stop
                    foreach ($item in $items) {
                        Move-ItemToTrash -Item $item -Exclude @()
                    }
                }
                if ($expanded -match '\*') {
                    $baseDir = Split-Path $expanded -Parent
                    if ($baseDir) { $dirsToClean += $baseDir }
                }
                else {
                    $dirsToClean += $expanded
                }
            }
            catch {
                Write-Warning "Path not found or invalid: $expanded"
            }
        }
    }
    else {
        foreach ($src in $config.sources) {
            $expanded = [System.Environment]::ExpandEnvironmentVariables($src.path)
            if (Test-Path -LiteralPath $expanded) {
                if (-not $RemoveEmptyDirs) {
                    $items = Get-ChildItem -LiteralPath $expanded -Force
                    foreach ($item in $items) {
                        Move-ItemToTrash -Item $item -Exclude $src.exclude
                    }
                }
                $dirsToClean += $expanded
            }
        }
    }

    if ($RemoveEmptyDirs) {
        $dirsToClean | Select-Object -Unique | ForEach-Object {
            Remove-EmptyDirectories -Path $_
        }
    }
}

if ($EmptyTrash -or $All) {
    Clear-Trash -Exclude $config.trashExclude
}

# 4. Results Display
if ($isInteractive -and -not [Console]::IsOutputRedirected) {
    $lines = @(
        "Folder Cleanup Summary",
        [string]::new([char]0x2500, 24)
    )
    if ($script:movedCount -gt 0) {
        $lines += "  [+] Moved to Trash: $script:movedCount item$([string]$(if ($script:movedCount -ne 1) { 's' }))"
    }
    if ($script:deletedCount -gt 0) {
        $lines += "  [-] Permanently deleted from Trash: $script:deletedCount item$([string]$(if ($script:deletedCount -ne 1) { 's' }))"
    }
    if ($script:skippedCount -gt 0) {
        $lines += "  [*] Excluded: $script:skippedCount item$([string]$(if ($script:skippedCount -ne 1) { 's' }))"
    }
    if ($script:movedCount -eq 0 -and $script:deletedCount -eq 0) {
        $lines += "  [+] All sources are clean"
    }
    $cardContent = $lines -join "`n"
    gum style --border normal --border-foreground 39 --padding "0 1" --margin "1 0" $cardContent
}