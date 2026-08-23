# Global variables
$global:computer = $env:COMPUTERNAME.ToLowerInvariant()

# Modules
Import-Module -Name PkgOps -Force -ErrorAction SilentlyContinue
Import-Module -Name FileOps -Force -ErrorAction SilentlyContinue

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

function touch {
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$names
    )
    foreach ($name in $names) {
        if (Test-Path $name) {
            (Get-Item $name).LastWriteTime = Get-Date
        }
        else {
            New-Item -ItemType File -Path $name -Force | Out-Null
        }
    }
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
        $answer = Read-Host "Are you sure you want to $verb the computer? (y/n)"
        if ($answer -eq "y") {
            $doAction = $true
        }
        else {
            Write-Host "$Action cancelled."
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
        Write-Host -NoNewline "$verb in "
        foreach ($i in 5..1) {
            Write-Host -NoNewline "$i.. "
            Start-Sleep -Seconds 1
        }
        
        $farewell = switch ($Action) {
            'Shutdown' { "Good bye!" }
            'Firmware' { "Happy tinkering!" }
            default    { "See you soon!" }
        }
        Write-Host $farewell
        Start-Sleep -Seconds 2
        
        switch ($Action) {
            'Shutdown' { shutdown /s /f /t 0 }
            'Reboot' { shutdown /r /f /t 0 }
            'Firmware' { shutdown /r /fw /f /t 0 }
            'Suspend' { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false) }
            'Hibernate' { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Hibernate', $false, $false) }
        }
    }
}

function PowerOff { param([switch]$y) Invoke-PowerAction -Action Shutdown -Force:$y }
function Reboot { param([switch]$y) Invoke-PowerAction -Action Reboot -Force:$y }
function Suspend { param([switch]$y) Invoke-PowerAction -Action Suspend -Force:$y }
function Hibernate { param([switch]$y) Invoke-PowerAction -Action Hibernate -Force:$y }
function RebootToBIOS { param([switch]$y) Invoke-PowerAction -Action Firmware -Force:$y }

function pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

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
        Write-Error "No file path specified."
        return
    }

    $FilePath = $args[0]

    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    }
    else {
        Write-Error "File path does not exist."
        return
    }

    $uri = "http://bin.christitus.com/documents"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Set-Clipboard $url
        Write-Output "$url copied to clipboard."
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

function dotmngr {
    & "$env:UserProfile\Git\dotmngr\dotmngr.ps1" -ConfigPath "$env:UserProfile\Git\dotfiles\dotmngr\$computer.json" @args
}

function whereis ($command) {
    Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
    
}

Set-Alias audiobook-dl "$env:UserProfile\Git\dotfiles\powershell\scripts\Download-Audiobook.ps1"

# Zoxide Initialization
. ([ScriptBlock]::Create((zoxide init powershell | Out-String)))
