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
    Start-Process wt -Verb RunAs -ArgumentList @(
        "--profile", $env:WT_PROFILE_ID,
        "-d", (Get-Location).Path
    )
}

function PowerOff {
    param(
        [switch]$y
    )

    if ($y) {
        shutdown /s /f /t 0
    }
    else {
        $answer = Read-Host "Are you sure you want to shutdown the computer? (y/n)"
        if ($answer -eq "y") {
            shutdown /s /f /t 0
        }
        else {
            Write-Host "Shutdown cancelled."
        }
    }
}

function Reboot {
    param(
        [switch]$y
    )

    if ($y) {
        shutdown /r /f /t 0
    }
    else {
        $answer = Read-Host "Are you sure you want to reboot the computer? (y/n)"
        if ($answer -eq "y") {
            shutdown /r /f /t 0
        }
        else {
            Write-Host "Reboot cancelled."
        }
    }
}

# Winget
function Search-Packages {
    $query = $args -join ' '

    Write-Host "Scoop`n" -ForegroundColor Cyan
    scoop-search $query

    Write-Host "`nWinget`n" -ForegroundColor Cyan
    winget search $query
}

function Update-AllPackages {
    Write-Host "Winget`n" -ForegroundColor Cyan
    winget source update
    winget upgrade --all --accept-package-agreements --accept-source-agreements
    winget upgrade winget --accept-package-agreements --accept-source-agreements

    Write-Host "`nScoop`n" -ForegroundColor Cyan
    scoop update
    scoop update -a
    scoop status

    Remove-DesktopIcons
}

function pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Windows Terminal
function rt {
    wt --profile $env:WT_PROFILE_ID -d (Get-Location).Path
    exit
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

function Remove-DesktopIcons {
    Remove-Item $env:USERPROFILE\Desktop\*.lnk
    Remove-Item C:\Users\Public\Desktop\*.lnk
}

function Clear-WindowsCache {
    $paths = @(
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\Temp",
        "$env:TEMP",
        "$env:LocalAppData\Package Cache",
        "$env:LocalAppData\pip\cache",
        "$env:AppData\stremio\stremio-server\stremio-cache"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    scoop cache rm -a
    scoop cleanup -a
}

# Scoop Search
. ([ScriptBlock]::Create((& scoop-search --hook | Out-String)))

# Zoxide Initialization
. ([ScriptBlock]::Create((zoxide init powershell | Out-String)))
