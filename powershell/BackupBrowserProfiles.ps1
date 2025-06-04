Write-Host "🛠️ Starting backup script for Firefox and Brave profiles..."

# Check if Brave, Firefox, and Flow Launcher are running
$isBraveRunning = Get-Process -Name "brave" -ErrorAction SilentlyContinue
$isFirefoxRunning = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
$isFlowLauncherRunning = Get-Process -Name "Flow.Launcher" -ErrorAction SilentlyContinue

# Close any running instances of Firefox, Brave, and Flow.Launcher
Write-Host "💀 Closing any running instances of Firefox, Brave, and Flow Launcher..."
if ($isBraveRunning) {
    Stop-Process -Name "brave" -Force -ErrorAction SilentlyContinue 
    Write-Host "✅ Brave closed." 
}
else { Write-Host "🤖 Brave not running." }

if ($isFirefoxRunning) {
    Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue 
    Write-Host "✅ Firefox closed." 
}
else { Write-Host "🤖 Firefox not running." }

if ($isFlowLauncherRunning) {
    Stop-Process -Name "Flow.Launcher" -Force -ErrorAction SilentlyContinue 
    Write-Host "✅ Flow Launcher closed." 
}
else { Write-Host "🤖 Flow Launcher not running." }

# Folder Paths
$backupRoot = "$env:USERPROFILE\Backups\BrowserProfiles"
$firefoxProfile = "$env:APPDATA\Mozilla\Firefox\Profiles"
$braveProfile = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"

# Program Paths
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$bravePath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
$firefoxPath = "C:\Program Files\Firefox Nightly\firefox.exe"
$flowLauncherPath = Join-Path ((Get-ChildItem -Path "$env:LOCALAPPDATA\FlowLauncher" -Directory | Where-Object { $_.Name -like "app-*" } | Sort-Object Name | Select-Object -Last 1).FullName) "Flow.Launcher.exe"

# Create backup folder if missing
if (-not (Test-Path -Path $backupRoot)) {
    New-Item -Path $backupRoot -ItemType Directory | Out-Null
    Write-Host "📁 Created backup folder: $backupRoot."
}

# Timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Backup Firefox Profiles folder
if (Test-Path $firefoxProfile) {
    $firefoxBackup = "$backupRoot\FirefoxProfiles_$timestamp.7z"
    Write-Host "⌛ Backing up Firefox Profiles folder..."
    Start-Process -FilePath $sevenZipPath -ArgumentList "a", "`"$firefoxBackup`"", "`"$firefoxProfile\*`"" -Wait
    Write-Host "✅ Firefox Profiles folder backup completed."
}
else {
    Write-Warning "⚠️ Firefox Profiles folder not found!"
}

# Backup Brave User Data folder
if (Test-Path $braveProfile) {
    $braveBackup = "$backupRoot\BraveUserData_$timestamp.7z"
    Write-Host "⌛ Backing up Brave User Data folder..."
    Start-Process -FilePath $sevenZipPath -ArgumentList "a", "`"$braveBackup`"", "`"$braveProfile\*`"" -Verb RunAs -Wait
    Write-Host "✅ Brave User Data folder backup completed."
}
else {
    Write-Warning "⚠️ Brave User Data folder not found!"
}

# Delete backups older than 30 days
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

# Backup folder location
Write-Host "📂 Backup folder: $backupRoot."

# Restart applications if they were running
if ($isFlowLauncherRunning) {
    Start-Process -FilePath $flowLauncherPath 
    Write-Host "✅ Flow Launcher restarted." 
}

if ($isBraveRunning) {
    Start-Process -FilePath $bravePath -ArgumentList "--profile-directory=`"Default`"" 
    Write-Host "✅ Brave restarted." 
}

if ($isFirefoxRunning) {
    Start-Process -FilePath $firefoxPath 
    Write-Host "✅ Firefox restarted." 
}

Write-Host "😀 Script completed successfully!"