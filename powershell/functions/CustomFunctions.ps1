# yt-dlp with aria2c downloader
function ytdlp {
    yt-dlp.exe --downloader aria2c @args
}

# Unzip files using 7-Zip
function uzip {
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

function pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Windows Terminal
function rt {
    wt --profile $env:WT_PROFILE_ID -d (Get-Location).Path
    exit
}

# HasteBin
function hb {
    if ($args.Length -eq 0) {
        Write-Error "No file path specified."
        return
    }
    
    $FilePath = $args[0]
    
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    }
    else {
        Write-Error "File path does not exist."
        return
    }
    
    $uri = "http://bin.christitus.com/documents"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Set-Clipboard $url
        Write-Output $url
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

# su
function su { 
    Start-Process wt -Verb RunAs -ArgumentList @(
        "--profile", $env:WT_PROFILE_ID,
        "-d", (Get-Location).Path
    )
}