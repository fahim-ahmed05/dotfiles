# Set your music folder path
$musicFolder = "$HOME\Music\YouTube Music"

# Check if ffmpeg is available
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg is not installed or not in PATH."
    exit
}

# Get all .m4a files in subdirectories
$m4aFiles = Get-ChildItem -Path $musicFolder -Recurse -Filter *.m4a

foreach ($m4a in $m4aFiles) {
    $mp3Path = [System.IO.Path]::ChangeExtension($m4a.FullName, ".mp3")

    # Skip if mp3 already exists
    if (Test-Path $mp3Path) {
        Write-Host "Skipping (mp3 exists): $($m4a.FullName)"
        continue
    }

    # Build ffmpeg command (CBR 128 kbps)
    $ffmpegArgs = @(
        "-i", "`"$($m4a.FullName)`"",
        "-codec:a", "libmp3lame",
        "-b:a", "128k",  # Constant Bitrate 128 kbps
        "`"$mp3Path`""
    )

    Write-Host "Converting: $($m4a.FullName)"
    $process = Start-Process -FilePath "ffmpeg" -ArgumentList $ffmpegArgs -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        # Conversion successful, delete original
        Remove-Item -Path $m4a.FullName -Force
        Write-Host "Deleted original: $($m4a.FullName)"
    } else {
        Write-Warning "Failed to convert: $($m4a.FullName)"
    }
}
