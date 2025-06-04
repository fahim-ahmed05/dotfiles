<#
.SYNOPSIS
Backs up browser and launcher profiles using 7-Zip, with shutdown, restart, and cleanup logic.

.DESCRIPTION
Uses a config array to define apps. Only apps with profile paths are backed up.
All defined apps will be closed and restarted if running.

.INPUTS
Run from PowerShell:
  .\Backup-Profiles.ps1

.EXAMPLE
[PSCustomObject]@{
    Name        = "AppName"
    ProcessName = "processname"
    ProfilePath = "full\path\to\profile"
    Executable  = "full\path\to\executable.exe"
    Arguments   = "optional arguments"
}
#>

Write-Host "🛠️ Starting backup script for browser profiles..."

# Apps to backup: Name, process, profile path, executable, optional args
$apps = @(
    [PSCustomObject]@{
        Name        = "Brave"
        ProcessName = "brave"
        ProfilePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
        Executable  = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
        Arguments   = "--profile-directory=`"Default`""
    },
    [PSCustomObject]@{
        Name        = "Firefox"
        ProcessName = "firefox"
        ProfilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        Executable  = "C:\Program Files\Firefox Nightly\firefox.exe"
        Arguments   = ""
    },
    [PSCustomObject]@{
        Name        = "Flow Launcher"
        ProcessName = "Flow.Launcher"
        ProfilePath = $null  # No backup needed
        Executable  = Join-Path (
                            (Get-ChildItem "$env:LOCALAPPDATA\FlowLauncher" -Directory |
            Where-Object { $_.Name -like "app-*" } |
            Sort-Object Name |
            Select-Object -Last 1).FullName
        ) "Flow.Launcher.exe"
        Arguments   = ""
    }
)

# Paths & settings
$backupRoot = Join-Path $env:USERPROFILE "Backups\BrowserProfiles"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Create backup folder if missing
if (-not (Test-Path -Path $backupRoot)) {
    New-Item -Path $backupRoot -ItemType Directory | Out-Null
    Write-Host "📁 Created backup folder: $backupRoot."
}

foreach ($app in $apps) {
    $name = $app.Name
    $process = $app.ProcessName
    $profilePath = $app.ProfilePath
    $exe = $app.Executable
    $appArgs = $app.Arguments

    # Check if running and stop
    $isRunning = Get-Process -Name $process -ErrorAction SilentlyContinue
    if ($isRunning) {
        Write-Host "💀 Closing $name..."
        Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
        Write-Host "✅ $name closed."
    }
    else {
        Write-Host "🤖 $name not running."
    }

    # Backup profiles if profile path is set
    if ($null -ne $profilePath -and $profilePath -ne "") {
        if (Test-Path $profilePath) {
            $backupFile = Join-Path $backupRoot ("${name.Replace(' ', '')}_$timestamp.7z")
            Write-Host "⌛ Backing up $name profile..."

            $zipArgs = @(
                'a'
                $backupFile
                "$profilePath\*"
            )
            Start-Process -FilePath $sevenZipPath -ArgumentList $zipArgs -Wait

            Write-Host "✅ $name profile backup completed."
        }
        else {
            Write-Warning "⚠️ $name profile path not found: $profilePath"
        }
    }
    else {
        Write-Warning "⚠️ No profile path defined for $name — skipping backup."
    }

    # Restart app if it was previously running
    if ($isRunning) {
        if (Test-Path $exe) {
            Write-Host "🔁 Restarting $name..."
            Start-Process -FilePath $exe -ArgumentList $appArgs
            Write-Host "✅ $name restarted."
        }
        else {
            Write-Warning "⚠️ Could not restart $name — executable not found."
        }
    }
}

# Cleanup backups older than 30 days
$oldBackups = Get-ChildItem -Path $backupRoot -Filter *.7z | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-30)
}

if ($oldBackups.Count -gt 0) {
    $oldBackups | Remove-Item -Force
    Write-Host "🗑️ Deleted $($oldBackups.Count) backup(s) older than 30 days."
}
else {
    Write-Host "🤖 No backups older than 30 days found to delete."
}

Write-Host "😀 Script completed successfully!"
