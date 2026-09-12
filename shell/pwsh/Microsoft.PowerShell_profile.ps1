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
Import-Module -Name PowerOps -Force -ErrorAction SilentlyContinue

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

function Stop-GitHubAction {
    [CmdletBinding()]
    param(
        [string]$Owner,
        [string]$Repo,
        [long]$RunId,
        [string]$Token,
        [switch]$Force
    )
    & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Stop-GitHubAction.ps1" @PSBoundParameters @args
}

function Pull-GitRepos {
    [CmdletBinding()]
    param(
        [string]$ConfigPath,
        [int]$Parallel,
        [switch]$FetchOnly,
        [switch]$DryRun
    )
    & "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Pull-GitRepos.ps1" @PSBoundParameters @args
}

# Zoxide Initialization
. ([ScriptBlock]::Create((zoxide init powershell | Out-String)))


