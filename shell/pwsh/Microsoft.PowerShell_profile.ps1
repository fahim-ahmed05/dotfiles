# Global variables
$global:computer = $env:COMPUTERNAME.ToLowerInvariant()

# Encoding / UTF-8 Unicode Support
$global:utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $global:utf8NoBom
[Console]::InputEncoding = $global:utf8NoBom
$OutputEncoding = $global:utf8NoBom
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"

# Modules
Import-Module -Name FileOps -ErrorAction SilentlyContinue
Import-Module -Name PowerOps -ErrorAction SilentlyContinue

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

# Non-interactive / redirected shells: skip prompt, PSReadLine and zoxide init
$global:isInteractiveTerminal = -not [Console]::IsOutputRedirected

# Cache folder for generated init scripts (avoids spawning oh-my-posh/zoxide on every launch)
$global:profileCacheDir = Join-Path (Split-Path $PROFILE) 'Cache'
if ($global:isInteractiveTerminal -and -not (Test-Path $global:profileCacheDir)) {
    New-Item -ItemType Directory -Path $global:profileCacheDir -Force | Out-Null
}

# Prompt (cached to avoid spawning oh-my-posh on every launch)
if ($global:isInteractiveTerminal) {
    $ompBin = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
    $ompCache = Join-Path $global:profileCacheDir 'omp-init.ps1'
    if ($ompBin -and (-not (Test-Path $ompCache) -or (Get-Item $ompBin).LastWriteTime -gt (Get-Item $ompCache).LastWriteTime)) {
        oh-my-posh init pwsh --config 'robbyrussell' | Out-File $ompCache -Encoding utf8
    }
    if (Test-Path $ompCache) { . $ompCache }
}

# Enhanced PSReadLine Configuration
if ($global:isInteractiveTerminal) {
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
        PredictionSource              = 'HistoryAndPlugin'
        PredictionViewStyle           = 'ListView'
        BellStyle                     = 'None'
    }
    Set-PSReadLineOption @PSReadLineOptions
    Remove-Variable PSReadLineOptions

    # Custom functions for PSReadLine
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
        $hasSensitive = $sensitive | Where-Object { $line -match $_ }
        return ($null -eq $hasSensitive)
    }

    # Improved prediction settings
    Set-PSReadLineOption -MaximumHistoryCount 10000
}

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

# xi.pe pastebin client (create/view/download/info/delete)
Set-Alias xipe "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Invoke-XiPaste.ps1"

function dotmngr {
    & "$env:UserProfile\Git\dotmngr\dotmngr.ps1" -ConfigPath "$env:UserProfile\Git\dotfiles\dotmngr\$computer.json" @args
}

function whereis ($command) {
    Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
    
}

Set-Alias audiobook-dl "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Download-Audiobook.ps1"

function Manage-GitHubAction {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet("dashboard", "run", "watch", "view", "cancel", "rerun", "download", "list")]
        [string]$Action = "dashboard",

        [string]$Owner,
        [string]$Repo,
        [long]$RunId,
        [string]$Workflow,
        [string]$Ref,
        [string]$Token,
        [switch]$FailedOnly,
        [switch]$Force
    )
    & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Manage-GitHubAction.ps1" @PSBoundParameters @args
}

# pkgmngr - unified Scoop + Winget package manager
. 'C:\Users\Fahim\Git\pkgmngr\pkg.ps1'

function Update-AllPackages {
    pkg update; pkg upgrade

    gum style --border normal --border-foreground 42 --margin "1 0" --padding "0 2" --bold "Upgrading UV Tools"
    uv tool upgrade --all

    gum style --border normal --border-foreground 212 --margin "1 0" --padding "0 2" --bold "Updating Git Repositories"

    $comp = if ($global:computer) { $global:computer } else { $env:COMPUTERNAME.ToLowerInvariant() }
    $gitScriptPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Pull-GitRepos.ps1"
    $gitConfigPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\configs\git_repos_$comp.json"

    if ((Test-Path $gitScriptPath) -and (Test-Path $gitConfigPath)) {
        & $gitScriptPath -ConfigPath $gitConfigPath
    }
    else {
        gum style --foreground 214 "[-] Git pull script or config for '$comp' not found. Skipping repository updates..."
    }

    gum style --border normal --border-foreground 245 --margin "1 0" --padding "0 2" --bold "Removing Desktop Icons"
    if (Get-Command Remove-DesktopIcons -ErrorAction SilentlyContinue) {
        Remove-DesktopIcons
    }

    gum style --border normal --border-foreground 42 --margin "1 0" --padding "0 3" --bold "All packages and repositories updated successfully!"
}

# Zoxide Initialization (cached to avoid spawning zoxide on every launch)
if ($global:isInteractiveTerminal) {
    $zoxideBin = (Get-Command zoxide -ErrorAction SilentlyContinue).Source
    $zoxideCache = Join-Path $global:profileCacheDir 'zoxide-init.ps1'
    if ($zoxideBin -and (-not (Test-Path $zoxideCache) -or (Get-Item $zoxideBin).LastWriteTime -gt (Get-Item $zoxideCache).LastWriteTime)) {
        zoxide init powershell | Out-File $zoxideCache -Encoding utf8
    }
    if (Test-Path $zoxideCache) { . $zoxideCache }
}


