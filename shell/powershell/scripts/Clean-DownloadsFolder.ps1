# Define the Downloads folder path
$downloadsPath = Join-Path $HOME "Downloads"

# Define the destination Trash folder (in your user home directory)
$trashPath = Join-Path $HOME "Trash"

# Create the Trash folder if it doesn't exist
if (-not (Test-Path $trashPath)) {
    New-Item -ItemType Directory -Path $trashPath | Out-Null
}

# Define folders to exclude (edit this list as you wish)
$excludeFolders = @("qBittorrent")

# Get all items in Downloads folder
$items = Get-ChildItem -Path $downloadsPath -Force

foreach ($item in $items) {
    if ($excludeFolders -notcontains $item.Name) {
        try {
            $destination = Join-Path $trashPath $item.Name

            # If something with the same name exists in Trash, make a unique name
            if (Test-Path $destination) {
                $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
                $destination = "$destination`_$timestamp"
            }

            Move-Item -Path $item.FullName -Destination $destination -Force -ErrorAction Stop
            Write-Host "Moved: $($item.FullName) -> $destination" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Skipped: $($item.FullName)" -ForegroundColor Yellow
    }
}

Write-Host "`nDownloads folder cleaned. Everything except $($excludeFolders -join ', ') has been moved to $trashPath." -ForegroundColor Cyan
