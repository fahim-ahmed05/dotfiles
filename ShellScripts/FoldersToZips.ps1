# Accept baseDir as a script argument or default to current directory
param (
    [string]$baseDir = (Get-Location).Path
)

# Path to 7-Zip executable
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Set output directory (same as baseDir)
$outputDir = $baseDir

# Get all subfolders in baseDir
$folders = Get-ChildItem -Path $baseDir -Directory

foreach ($folder in $folders) {
    $folderPath = Join-Path $baseDir $folder.Name
    $zipName = "$($folder.Name).zip"
    $zipPath = Join-Path $outputDir $zipName

    # Compress the folder's contents into a zip
    & "$sevenZipPath" a -tzip "$zipPath" "$folderPath\*" | Out-Null

    Write-Host ("Zipped: {0} → {1}" -f $folder.Name, $zipName) -ForegroundColor Green

    # Delete the original folder after successful compression
    Remove-ItemSafely -Path $folderPath
    Write-Host ("Deleted folder: {0}" -f $folder.Name) -ForegroundColor Red
}
