# Close any running instances of Firefox, Brave, and Flow.Launcher
Write-Host "💀 Closing any running instances of Firefox, Brave, and Flow.Launcher..."
Stop-Process -Name "firefox","brave", "Flow Launcher" -Force -ErrorAction SilentlyContinue
Write-Host "✅ Done."

# Paths
$backupRoot = "$env:USERPROFILE\Backups\BrowserProfiles"
$firefoxProfile = "$env:APPDATA\Mozilla\Firefox\Profiles"
$braveProfile = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Create backup folder if missing
if (-not (Test-Path -Path $backupRoot)) {
    New-Item -Path $backupRoot -ItemType Directory | Out-Null
}

# Timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Backup Firefox Profiles folder
if (Test-Path $firefoxProfile) {
    $firefoxBackup = "$backupRoot\FirefoxProfiles_$timestamp.7z"
    Write-Host "⌛ Backing up Firefox Profiles folder..."
    & "$sevenZipPath" a "$firefoxBackup" "$firefoxProfile\*" | Out-Null
    Write-Host "✅ Done."
} else {
    Write-Warning "⚠️ Firefox Profiles folder not found!"
}

# Backup Brave User Data folder
if (Test-Path $braveProfile) {
    $braveBackup = "$backupRoot\BraveUserData_$timestamp.7z"
    Write-Host "⌛ Backing up Brave User Data folder..."
    & "$sevenZipPath" a "$braveBackup" "$braveProfile\*" | Out-Null
    Write-Host "✅ Done."
} else {
    Write-Warning "⚠️ Brave User Data folder not found!"
}

# Delete backups older than 30 days
$oldBackups = Get-ChildItem -Path $backupRoot -Filter *.7z | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-30)
}

if ($oldBackups.Count -gt 0) {
    $oldBackups | Remove-Item -Force
    Write-Host "🗑️ Deleted $($oldBackups.Count) backup(s) older than 30 days."
} else {
    Write-Host "🤖 No backups older than 30 days found to delete."
}

# Backup folder location
Write-Host "📂 Backup folder: $backupRoot."

# Start Flow Launcher
Start-Process "$env:LOCALAPPDATA\FlowLauncher\Flow.Launcher.exe"
Write-Host "🚀 Flow Launcher started."