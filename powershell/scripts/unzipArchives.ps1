<#
# Extract a specific archive to a folder named after the archive
uzip archive.zip

# Extract all .zip archives in the current directory
uzip zip

# Extract all archives matching a wildcard pattern (e.g., all zip files starting with "test")
uzip test*.zip

# Extract a specific archive to a custom folder
uzip archive.zip C:\ExtractHere

# Extract all .rar files in the current directory to a custom folder
uzip rar D:\MyExtractedRars

# Extract an archive even if the target folder already exists (overwrite)
uzip archive.zip -Force
uzip archive.zip -F

# Extract all archives matching a pattern with allowed extensions
uzip myarchive*

# Extract all archives in the current directory
uzip

# Extract an archive using relative or absolute path
uzip .\folder\archive.7z
uzip C:\Downloads\archive.7z

# Extract archives matching a wildcard pattern
uzip *.7z

# Extract archives of multiple types (using extension shortcut)
uzip 7z

# Extract an archive with spaces in the name
uzip "my archive.zip"

# Force extract all .zip files even if folders exist
uzip zip -Force
uzip zip -F
#>

# Unzip files using 7-Zip
function unzip {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Pattern = "*",

        [Parameter(Position = 1)]
        [string]$ExtractPath,

        [switch]$Force
    )

    $AllowedExtensions = @("zip", "7z", "rar", "tar", "gz", "xz", "bz2")
    $sevenZip = "C:\Program Files\7-Zip\7z.exe"

    if (-not (Test-Path $sevenZip)) {
        Write-Host "ERROR: 7-Zip not found at $sevenZip" -ForegroundColor Red
        return
    }

    $currentLocation = (Get-Location).Path

    # Determine files to extract
    if ($AllowedExtensions -contains $Pattern.ToLower()) {
        # If parameter is an extension only (e.g., "zip"), extract all files with that extension
        $files = Get-ChildItem -Path $currentLocation -Filter "*.$Pattern" -File -ErrorAction SilentlyContinue
        if (-not $files) {
            Write-Host "ERROR: No *.$Pattern files found in $currentLocation" -ForegroundColor Red
            return
        }
    }
    elseif (Test-Path $Pattern) {
        # If full filename/path given and exists, extract it
        $fileItem = Get-Item -Path $Pattern -ErrorAction SilentlyContinue
        if ($fileItem -and -not $fileItem.PSIsContainer) {
            $files = @($fileItem)
        }
        else {
            Write-Host "ERROR: File '$Pattern' not found or is not a file." -ForegroundColor Red
            return
        }
    }
    elseif ($Pattern -like "*.*") {
        # If a wildcard pattern with extension, get matching files
        $files = Get-ChildItem -Path $currentLocation -Filter $Pattern -File -ErrorAction SilentlyContinue
        if (-not $files) {
            Write-Host "ERROR: No files matching '$Pattern' found." -ForegroundColor Red
            return
        }
    }
    else {
        # Otherwise try to find files matching pattern with allowed archive extensions
        $files = @()
        foreach ($ext in $AllowedExtensions) {
            $files += Get-ChildItem -Path $currentLocation -Filter "$Pattern.$ext" -File -ErrorAction SilentlyContinue
        }
        if (-not $files) {
            Write-Host "ERROR: No archive files found matching pattern '$Pattern' with allowed extensions." -ForegroundColor Red
            return
        }
    }

    foreach ($file in $files) {
        # Determine extraction directory
        if ($ExtractPath) {
            if (-not (Test-Path $ExtractPath)) {
                New-Item -ItemType Directory -Path $ExtractPath | Out-Null
            }
            $extractDir = (Resolve-Path $ExtractPath).Path
        }
        else {
            $extractDir = Join-Path $currentLocation $file.BaseName
            if (Test-Path $extractDir -and -not $Force) {
                Write-Host "Skipping $($file.Name) because folder '$extractDir' already exists. Use -Force to overwrite." -ForegroundColor Yellow
                continue
            }
            elseif (Test-Path $extractDir -and $Force) {
                Write-Host "Folder '$extractDir' exists, but -Force specified. Extracting anyway." -ForegroundColor Yellow
            }
            else {
                New-Item -ItemType Directory -Path $extractDir | Out-Null
            }
        }

        Write-Host "Extracting $($file.Name) to $extractDir" -ForegroundColor Cyan
        & $sevenZip x $file.FullName "-o$extractDir" -y | Out-Null
    }
}
