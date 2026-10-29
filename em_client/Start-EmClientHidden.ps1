#Requires -Version 5.1
<#
.SYNOPSIS
    Starts eM Client and makes sure its window does not stay on screen.

.DESCRIPTION
    "start /min" only passes a hint to the process it creates, and that hint is
    unreliable for eM Client:

      * the app is installed as a Microsoft Store package now, while
        "C:\Program Files (x86)\eM Client\MailClient.exe" is a leftover win32
        launcher that just activates the Store app - so the window belongs to a
        different process that never receives the hint;
      * eM Client creates and shows its own window while starting up, which
        overrides whatever start-up window state it was given.

    Instead of asking nicely, this script launches the app and then polls its
    windows, forcing any window that is on screen back to minimized until the
    app settles (either minimized or hidden in the tray/spine).

.PARAMETER TimeoutSeconds
    Hard limit for each phase: waiting for the process to appear, and watching
    its windows afterwards. The script normally finishes in a few seconds.

.PARAMETER SkipLaunch
    Only handle an already running instance, start nothing.

.PARAMETER ProcessNames
    Process names that count as eM Client. Override it to test the window
    forcing against another program.

.PARAMETER LogPath
    Append what happened to this file. The script normally runs invisibly at
    logon, so this is the only way to see why it did or did not act.

.EXAMPLE
    .\Start-EmClientHidden.ps1 -Verbose
#>
[CmdletBinding()]
param(
    [ValidateRange(5, 600)]
    [int]$TimeoutSeconds = 90,

    [switch]$SkipLaunch,

    [string[]]$ProcessNames = @('MailClient', 'emclient', 'eMClient'),

    [string]$LogPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# SW_MINIMIZE
$SW_MINIMIZE = 6

if (-not ('EmClient.Native' -as [type])) {
    Add-Type -Namespace 'EmClient' -Name 'Native' -MemberDefinition @'
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool IsIconic(IntPtr hWnd);
'@
}

function Write-Log {
    param([string]$Message)

    Write-Verbose $Message
    if (-not $LogPath) { return }

    if ((Test-Path -LiteralPath $LogPath) -and ((Get-Item -LiteralPath $LogPath).Length -gt 65536)) {
        Clear-Content -LiteralPath $LogPath
    }
    try {
        $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
        Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
    }
    catch { }
}

function Get-EmClientProcess {
    # A tray-hosted instance has no window at all, so the process list is what
    # tells whether eM Client is already up.
    foreach ($name in $ProcessNames) {
        Get-Process -Name $name -ErrorAction SilentlyContinue
    }
}

function Get-EmClientWindow {
    foreach ($p in @(Get-EmClientProcess)) {
        try { $handle = $p.MainWindowHandle } catch { $handle = [IntPtr]::Zero }
        if ($handle -ne [IntPtr]::Zero) {
            [pscustomobject]@{ Id = $p.Id; Handle = $handle }
        }
    }
}

function Get-LiveWindow {
    # @() at the call site, not here: a function returning a single-element
    # array hands the caller a scalar, which then breaks .Count.
    Get-EmClientWindow | Where-Object { -not [EmClient.Native]::IsIconic($_.Handle) }
}

function Resolve-EmClientLauncher {
    # App execution alias of the Store package, resolved through PATH.
    $alias = Get-Command -Name 'emclient.exe', 'eMClientStore.exe' -CommandType Application `
        -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($alias) { return $alias.Source }

    foreach ($candidate in @(
            (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\emclient.exe'),
            'C:\Program Files\eM Client\MailClient.exe',
            'C:\Program Files (x86)\eM Client\MailClient.exe'
        )) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $null
}

if ($SkipLaunch) {
    Write-Log 'launch skipped'
}
elseif (@(Get-EmClientProcess).Count -gt 0) {
    Write-Log 'eM Client is already running, not starting a second instance'
}
else {
    $launcher = Resolve-EmClientLauncher
    if (-not $launcher) {
        Write-Log 'ERROR: no eM Client executable found'
    }
    else {
        try {
            # The window is forced away below, so no /min trickery here.
            $started = Start-Process -FilePath $launcher -WindowStyle Minimized -PassThru
            Write-Log ('launched {0} (pid {1})' -f $launcher, $started.Id)
        }
        catch {
            Write-Log ('ERROR: launch failed: {0}' -f $_.Exception.Message)
        }
    }
}

# Phase 1: wait for the MailClient process itself. The launcher alias only
# hands the request over, and a cold boot can keep the real process away for a
# while, so nothing is concluded until it shows up.
$waitUntil = [DateTime]::Now.AddSeconds($TimeoutSeconds)
while ([DateTime]::Now -lt $waitUntil) {
    if (@(Get-EmClientProcess).Count -gt 0) { break }
    Start-Sleep -Milliseconds 250
}

if (@(Get-EmClientProcess).Count -eq 0) {
    Write-Log ('done: no eM Client process appeared within {0}s' -f $TimeoutSeconds)
    exit 1
}
Write-Log ('pid(s) {0} running, watching for its window' -f ((@(Get-EmClientProcess) | ForEach-Object Id) -join ', '))

# Phase 2: keep pushing any on-screen window back to minimized. Leaving is only
# safe once the app has had time to show what it wanted:
#   * a window was minimized and stayed out of the way for 3 s, or
#   * 15 s went by with nothing on screen (the app came up straight in the tray).
$pollMs = 100
$settleRounds = [math]::Ceiling(3000 / $pollMs)
$idleRounds = [math]::Ceiling(15000 / $pollMs)
$rounds = 0
$quiet = 0
$minimizedCount = 0
$watchUntil = [DateTime]::Now.AddSeconds($TimeoutSeconds)

while ([DateTime]::Now -lt $watchUntil) {
    $rounds++
    $live = @(Get-LiveWindow)

    if ($live.Count -eq 0) {
        $quiet++
        if (($minimizedCount -gt 0 -and $quiet -ge $settleRounds) -or ($quiet -ge $idleRounds)) { break }
    }
    else {
        $quiet = 0
        foreach ($window in $live) {
            Write-Log ('minimizing window {0} of pid {1}' -f $window.Handle, $window.Id)
            [void][EmClient.Native]::ShowWindow($window.Handle, $SW_MINIMIZE)
            $minimizedCount++
        }
    }

    Start-Sleep -Milliseconds $pollMs
}

$watched = [math]::Round($rounds * $pollMs / 1000, 1)
if ($minimizedCount -gt 0) {
    Write-Log ('done: {0} window(s) minimized in {1}s' -f $minimizedCount, $watched)
}
else {
    Write-Log ('done: no window appeared in {0}s, the app came up straight from the tray' -f $watched)
}

$still = @(Get-LiveWindow).Count
if ($still -gt 0) {
    Write-Log ('WARNING: {0} window(s) still on screen after {1}s' -f $still, $TimeoutSeconds)
    exit 1
}
exit 0
