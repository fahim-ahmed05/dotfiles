<#
.SYNOPSIS
Compresses each folder in a given directory into a .zip or .7z file, skipping folders that are already archived.

.DESCRIPTION
- Accepts a target directory (defaults to current).
- Compresses each subfolder into an archive using 7-Zip.
- Sends original folders to trash using your `bin` function.
- Skips folders if archive already exists.

.PARAMETER baseDir
Base directory where folders should be compressed.

.PARAMETER Format
Archive format to use: 'zip' (default) or '7z'.

.EXAMPLE
.\ZipAndBin.ps1
.\ZipAndBin.ps1 -baseDir "C:\Projects"
.\ZipAndBin.ps1 -Format 7z
#>

param (
    [string]$baseDir = (Get-Location).Path,
    [ValidateSet("zip", "7z")]
    [string]$Format = "zip"
)

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $sevenZipPath)) {
    Write-Error "❌ 7-Zip not found at $sevenZipPath"
    exit 1
}

$outputDir = $baseDir
$folders = Get-ChildItem -Path $baseDir -Directory

foreach ($folder in $folders) {
    $folderPath = Join-Path $baseDir $folder.Name
    $archiveName = "$($folder.Name).$Format"
    $archivePath = Join-Path $outputDir $archiveName

    # Skip if archive already exists
    if (Test-Path $archivePath) {
        Write-Host "⏩ Skipping '$($folder.Name)' — archive already exists." -ForegroundColor Yellow
        continue
    }

    Write-Host "📦 Compressing: $folderPath → $archiveName" -ForegroundColor Cyan
    & "$sevenZipPath" a -t$Format "$archivePath" "$folderPath\*" | Out-Null

    if (Test-Path $archivePath) {
        Write-Host "✅ Zipped: $archiveName" -ForegroundColor Green

        try {
            bin $folderPath
            Write-Host "🗑️ Moved to Trash: $($folder.Name)" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "❌ Failed to move $($folder.Name) to trash."
        }
    }
    else {
        Write-Warning "⚠️ Archive not created: $archiveName"
    }
}
