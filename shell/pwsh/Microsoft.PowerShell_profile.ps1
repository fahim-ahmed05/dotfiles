# Global variables
$global:computer = $env:COMPUTERNAME.ToLowerInvariant()

# Encoding / UTF-8 Unicode Support
chcp 65001 >$null
$global:utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $global:utf8NoBom
[Console]::InputEncoding  = $global:utf8NoBom
$OutputEncoding           = $global:utf8NoBom
$env:PYTHONIOENCODING     = "utf-8"
$env:PYTHONUTF8           = "1"

# Modules
Import-Module -Name PkgOps -Force -ErrorAction SilentlyContinue
Import-Module -Name FileOps -Force -ErrorAction SilentlyContinue

# Coreutils
@(
    'cat'
    'cp'
    'mv'
    'rm'
    'rmdir'
    'tee'
    'dir'
    'echo'
    'kill'
    'pwd'
    'sleep'
    'diff'
    'sort'
) | ForEach-Object {
    Remove-Alias $_ -Force -ErrorAction SilentlyContinue
}
Remove-Item Function:\mkdir -Force -ErrorAction SilentlyContinue
function sort {
    & "$env:USERPROFILE\scoop\shims\sort.exe" @args
}
function expand {
    & "$env:USERPROFILE\scoop\shims\expand.exe" @args
}
function more {
    & "$env:USERPROFILE\scoop\shims\more.exe" @args
}
function timeout {
    & "$env:USERPROFILE\scoop\shims\timeout.exe" @args
}
function whoami {
    & "$env:USERPROFILE\scoop\shims\whoami.exe" @args
}
function curl {
    & "$env:USERPROFILE\scoop\shims\curl.exe" @args
}
function find {
    & "$env:USERPROFILE\scoop\shims\find.exe" @args
}
function hostname {
    & "$env:USERPROFILE\scoop\shims\hostname.exe" @args
}

# Aliases
Set-Alias -Name ls -Value eza
Set-Alias -Name ff -Value fzf
Set-Alias -Name cd -Value z -Option AllScope

# Prompt
oh-my-posh init pwsh --config 'robbyrussell' | Invoke-Expression

# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode                      = 'Windows'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
        Command   = '#61afef'  # Blue
        Parameter = '#98c379'  # Green
        Operator  = '#56b6c2'  # Cyan
        Variable  = '#c678dd'  # Purple
        String    = '#e5c07b'  # Yellow
        Number    = '#d19a66'  # Orange
        Type      = '#7f91a8'  # Steel Blue
        Comment   = '#837a86'  # Dusty Mauve
        Keyword   = '#d16d9e'  # Pink
        Error     = '#e06c75'  # Red
    }
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    BellStyle                     = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

# Custom functions for PSReadLine
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

# Improved prediction settings
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000

function mkcd {
    param(
        [Parameter(Mandatory = $true)]
        [string]$dir
    )
    if (-not [string]::IsNullOrWhiteSpace($dir)) {
        if (-not (Test-Path -Path $dir -PathType Container)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Set-Location -Path $dir
    }
    else {
        Write-Host "ERROR: Directory name is required." -ForegroundColor Red
    }
}

function ll {
    param(
        [Parameter(Mandatory = $false)]
        [string]$path = (Get-Location).Path
    )
    eza -l -h --git --icons=always --time-style '+%d %h %I:%M %P' --color=always --group-directories-first $path
}

function la {
    param(
        [Parameter(Mandatory = $false)]
        [string]$path = (Get-Location).Path
    )
    eza -la -h --git --icons=always --time-style '+%d %h %I:%M %P' --color=always --group-directories-first $path
}

function su {
    if ($env:ALACRITTY_LOG) {
        Start-Process alacritty -Verb RunAs -ArgumentList @(
            "--working-directory", (Get-Location).Path
        )
    }
    else {
        Start-Process wt -Verb RunAs -ArgumentList @(
            "--profile", $env:WT_PROFILE_ID,
            "-d", (Get-Location).Path
        )
    }
}

function Invoke-PowerAction {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Shutdown', 'Reboot', 'Suspend', 'Hibernate', 'Firmware')]
        [string]$Action,
        [switch]$Force
    )

    $doAction = $false
    if ($Force) {
        $doAction = $true
    }
    else {
        $verb = if ($Action -eq 'Firmware') { "reboot to BIOS" } else { $Action.ToLower() }
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum confirm "Are you sure you want to $verb the computer?"
            if ($LASTEXITCODE -eq 0) {
                $doAction = $true
            }
        }
        else {
            $answer = Read-Host "Are you sure you want to $verb the computer? (y/n)"
            if ($answer -eq "y") {
                $doAction = $true
            }
            else {
                Write-Host "$Action cancelled."
            }
        }
    }

    if ($doAction) {
        $verb = switch ($Action) {
            'Firmware'  { "Rebooting to BIOS" }
            'Shutdown'  { "Shutting down" }
            'Reboot'    { "Rebooting" }
            'Suspend'   { "Suspending" }
            'Hibernate' { "Hibernating" }
        }

        $color = switch ($Action) {
            'Shutdown'  { 203 }
            'Reboot'    { 214 }
            'Firmware'  { 141 }
            default     { 39 }
        }

        $farewell = switch ($Action) {
            'Shutdown' { "Good bye!" }
            'Firmware' { "Happy tinkering!" }
            default    { "See you soon!" }
        }

        $esc = [char]27
        $barWidth = 20

        for ($i = 5; $i -gt 0; $i--) {
            $pct = (5 - $i) / 5
            $filled = [int]($pct * $barWidth)
            $empty = $barWidth - $filled
            $bar = "$esc[38;5;${color}m" + ("█" * $filled) + "$esc[38;5;238m" + ("░" * $empty) + "$esc[0m"
            Write-Host -NoNewline "`r  $esc[1m$verb$esc[0m in ${i}s  [$bar] "
            Start-Sleep -Seconds 1
        }
        $fullBar = "$esc[38;5;${color}m" + ("█" * $barWidth) + "$esc[0m"
        Write-Host "`r  $esc[1m$verb$esc[0m in 0s  [$fullBar]  $esc[38;5;${color}m$farewell$esc[0m    "
        Start-Sleep -Seconds 1
        
        switch ($Action) {
            'Shutdown'  { shutdown /s /f /t 0 }
            'Reboot'    { shutdown /r /f /t 0 }
            'Firmware'  { shutdown /r /fw /f /t 0 }
            'Suspend'   { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false) }
            'Hibernate' { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Hibernate', $false, $false) }
        }
    }
}

function PowerOff { param([switch]$y) Invoke-PowerAction -Action Shutdown -Force:$y }
function Reboot { param([switch]$y) Invoke-PowerAction -Action Reboot -Force:$y }
function Suspend { param([switch]$y) Invoke-PowerAction -Action Suspend -Force:$y }
function Hibernate { param([switch]$y) Invoke-PowerAction -Action Hibernate -Force:$y }
function RebootToBIOS { param([switch]$y) Invoke-PowerAction -Action Firmware -Force:$y }

function power {
    <#
    .SYNOPSIS
        Interactive system power menu powered by gum.
    #>
    if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
        Write-Host "gum is required for the interactive power menu." -ForegroundColor Red
        return
    }

    $choice = gum choose --cursor="▶ " --cursor.foreground 214 "Shutdown" "Reboot" "Suspend" "Hibernate" "Reboot to BIOS"
    if (-not $choice) { return }

    $action = if ($choice -eq "Reboot to BIOS") { "Firmware" } else { $choice }
    Invoke-PowerAction -Action $action
}

function ip {
    <#
    .SYNOPSIS
        Displays public and private IP addresses in a styled card.
    #>
    $publicIP = try {
        (Invoke-RestMethod http://ifconfig.me/ip -UseBasicParsing -TimeoutSec 3).Trim()
    }
    catch {
        "Unavailable"
    }

    $socket = New-Object System.Net.Sockets.UdpClient
    $privateIP = try {
        $socket.Connect('8.8.8.8', 53)
        $socket.Client.LocalEndPoint.Address.ToString()
    }
    catch {
        "Unavailable"
    }
    finally {
        $socket.Close()
    }

    if (Get-Command gum -ErrorAction SilentlyContinue) {
        gum style --border normal --border-foreground 39 --padding "0 2" `
            "Public  IP : $publicIP" `
            "Private IP : $privateIP"
    }
    else {
        Write-Host "Public  IP: $publicIP" -ForegroundColor Green
        Write-Host "Private IP: $privateIP" -ForegroundColor Cyan
    }
}

# Restart Terminal
function rt {
    $currentPath = (Get-Location).Path

    if ($env:WT_SESSION) {
        wt --profile $env:WT_PROFILE_ID -d "$currentPath"
        exit
    } 
    elseif ($env:ALACRITTY_LOG) {
        Start-Process alacritty -ArgumentList "--working-directory `"$currentPath`""
        exit
    } 
    else {
        Write-Warning "Terminal not recognized. This function currently supports Windows Terminal and Alacritty."
    }
}

# HasteBin
function hb {
    if ($args.Length -eq 0) {
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum style --foreground 203 "[-] No file path specified."
        }
        else {
            Write-Error "No file path specified."
        }
        return
    }

    $FilePath = $args[0]

    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    }
    else {
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum style --foreground 203 "[-] File path does not exist: $FilePath"
        }
        else {
            Write-Error "File path does not exist."
        }
        return
    }

    $uri = "http://bin.christitus.com/documents"
    try {
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum style --foreground 245 "Uploading to Hastebin..."
        }
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -TimeoutSec 10 -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Set-Clipboard $url
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum style --border normal --border-foreground 42 --padding "0 2" `
                "Uploaded to Hastebin!" `
                "URL : $url (copied to clipboard)"
        }
        else {
            Write-Output "$url copied to clipboard."
        }
    }
    catch {
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum style --foreground 203 "[-] Failed to upload document: $($_.Exception.Message)"
        }
        else {
            Write-Error "Failed to upload the document. Error: $_"
        }
    }
}

function dotmngr {
    & "$env:UserProfile\Git\dotmngr\dotmngr.ps1" -ConfigPath "$env:UserProfile\Git\dotfiles\dotmngr\$computer.json" @args
}

function whereis ($command) {
    Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
    
}

Set-Alias audiobook-dl "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Download-Audiobook.ps1"

# Zoxide Initialization
. ([ScriptBlock]::Create((zoxide init powershell | Out-String)))


