# Define the Trash folder path
$trashPath = Join-Path $HOME "Trash"

# Define folders to exclude from deletion
$excludeFolders = @("KeepThis") 

# Check if the Trash folder exists
if (-not (Test-Path $trashPath)) {
    Write-Host "Error: $trashPath does not exist." -ForegroundColor Red
    exit
}

# Get all items inside the Trash folder
$items = Get-ChildItem -Path $trashPath -Force

foreach ($item in $items) {
    if ($excludeFolders -notcontains $item.Name) {
        try {
            if ($item.PSIsContainer) {
                # Remove directories and contents
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
            } else {
                # Remove individual files
                Remove-Item -Path $item.FullName -Force -ErrorAction Stop
            }
            Write-Host "Deleted: $($item.FullName)" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed: $($item.FullName). Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Skipped: $($item.FullName)" -ForegroundColor Yellow
    }
}

Write-Host "`nTrash folder emptied. Everything except $($excludeFolders -join ', ') has been deleted." -ForegroundColor Cyan
