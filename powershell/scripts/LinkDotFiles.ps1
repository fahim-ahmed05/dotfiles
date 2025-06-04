<#
.SYNOPSIS
Dotfile symlink manager with backup and force-overwrite options.

.DESCRIPTION
This script links dotfiles and config folders from a Git repo to system locations.
Existing non-symlinks are backed up to ~/Trash/<timestamp>.

.PARAMETER Force
Forces overwriting symlinks even if already correct.

.PARAMETER DryRun
Simulates actions without making any changes.

.INPUTS
.\LinkDotFiles.ps1                  # Default run without force or dry run
.\LinkDotFiles.ps1 -Force           # Force overwrite existing symlinks
.\LinkDotFiles.ps1 -DryRun          # Simulate actions without changes
.\LinkDotFiles.ps1 -Force -DryRun   # Force overwrite and simulate actions

.EXAMPLE
(Join-Path "config\git" ".gitconfig")  = "$env:USERPROFILE\.gitconfig"          # File
(Join-Path "nvim" "")                  = "$env:USERPROFILE\AppData\Local\nvim"  # Folder
#>

param(
    [switch]$Force,
    [switch]$DryRun
)

$gitRoot = "C:\Users\Fahim\git\dotfiles"
$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$backupRoot = Join-Path "$env:USERPROFILE\Trash\Backups" $timestamp

# Define mappings: relative git path => absolute system target path
$configMappings = @{
    (Join-Path "windows_terminal" "settings.json")              = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    (Join-Path "powershell" "Microsoft.PowerShell_profile.ps1") = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    (Join-Path "config\git" ".gitconfig")                       = "$env:USERPROFILE\.gitconfig"
}

foreach ($relativeSource in $configMappings.Keys) {
    $source = Join-Path $gitRoot $relativeSource
    $target = $configMappings[$relativeSource]

    if (-not (Test-Path $source)) {
        Write-Warning "⛔ Source path not found: $source"
        continue
    }

    $targetDir = if (Test-Path $source -and (Get-Item $source).PSIsContainer) {
        Split-Path $target -Parent
    }
    else {
        Split-Path $target
    }

    if (-not (Test-Path $targetDir)) {
        Write-Host "📁 Create directory: $targetDir"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
    }

    $shouldLink = $true

    if (Test-Path $target) {
        $targetItem = Get-Item $target -Force
        if ($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $currentTarget = $targetItem.Target
            if ($currentTarget -eq $source -and -not $Force.IsPresent) {
                Write-Host "✅ Symlink already exist: $target -> $source"
                $shouldLink = $false
            }
        }
        else {
            $backupPath = Join-Path $backupRoot ($target -replace [regex]::Escape($env:USERPROFILE), "").TrimStart("\")
            $backupDir = Split-Path $backupPath

            Write-Host "📥 Moving existing item to: $backupPath"
            if (-not $DryRun) {
                if (-not (Test-Path $backupDir)) {
                    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                }
                Move-Item -Path $target -Destination $backupPath -Force
            }
        }
    }

    if ($shouldLink) {
        Write-Host "🔗 Creating symlink: $target -> $source"
        if (-not $DryRun) {
            if ((Get-Item $source).PSIsContainer) {
                New-Item -ItemType SymbolicLink -Path $target -Value $source -Force -TargetType Directory | Out-Null
            }
            else {
                New-Item -ItemType SymbolicLink -Path $target -Value $source -Force -TargetType File | Out-Null
            }
        }
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "✅ Dry run complete. No changes were made."
} else {
    Write-Host "✅ All requested config files and folders have been processed."
}
