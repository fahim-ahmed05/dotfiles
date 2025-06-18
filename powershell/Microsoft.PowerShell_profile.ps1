# Aliases
Set-Alias -Name ls -Value eza
Set-Alias -Name cd -Value z -Option AllScope

# Prompt
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\robbyrussell.omp.json" | Invoke-Expression

# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode                      = 'Windows'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
        Command   = '#87CEEB'  # SkyBlue
        Parameter = '#98FB98'  # PaleGreen
        Operator  = '#FFB6C1'  # LightPink
        Variable  = '#DDA0DD'  # Plum
        String    = '#FFDAB9'  # PeachPuff
        Number    = '#B0E0E6'  # PowderBlue
        Type      = '#F0E68C'  # Khaki
        Comment   = '#D3D3D3'  # LightGray
        Keyword   = '#8367c7'  # Violet
        Error     = '#FF6347'  # Red
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

# Custom completion for common commands
$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $customCompletions = @{
        'git'    = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
        'winget' = @('search', 'install', 'show', 'list', 'pin', 'upgrade', 'uninstall', 'source', 'settings')
    }
    
    $command = $commandAst.CommandElements[0].Value
    if ($customCompletions.ContainsKey($command)) {
        $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
Register-ArgumentCompleter -Native -CommandName git, winget -ScriptBlock $scriptblock

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

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

# Winget Commands
function ws {
    winget search @args
}

function wi {
    winget install @args --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5

    if (Get-Command rmDesktopIcons -ErrorAction SilentlyContinue) {
        rmDesktopIcons
    }
}

function wu {
    if (-not (Test-InternetConnection)) {
        return
    }

    Write-Host "`n📦  Updating winget packages...`n" -ForegroundColor Cyan
    try {
        winget source update
        winget upgrade --all --accept-package-agreements --accept-source-agreements
    }
    catch {
        Write-Host "❌ Winget update failed." -ForegroundColor Red
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "`n📦  Updating scoop packages...`n" -ForegroundColor Cyan
        try {
            scoop update
            scoop cleanup *
        }
        catch {
            Write-Host "❌ Scoop update or cleanup failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ Scoop not installed." -ForegroundColor Yellow
    }

    if (Get-Command python.exe -ErrorAction SilentlyContinue) {
        Write-Host "`n🐍  Updating pip...`n" -ForegroundColor Cyan
        try {
            python.exe -m pip install --upgrade pip
        }
        catch {
            Write-Host "❌ pip upgrade failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ Python not installed." -ForegroundColor Yellow
    }

    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        Write-Host "`n📦  Updating pipx packages...`n" -ForegroundColor Cyan
        try {
            pipx upgrade-all
        }
        catch {
            Write-Host "❌ pipx upgrade failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ pipx not installed." -ForegroundColor Yellow
    }

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "`n📦  Updating Chocolatey packages...`n" -ForegroundColor Cyan
        try {
            sudo choco upgrade all -y
        }
        catch {
            Write-Host "❌ Chocolatey upgrade failed." -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️ Chocolatey not installed." -ForegroundColor Yellow
    }

    rmDesktopIcons
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

function rmDesktopIcons {
    Remove-Item -Path "$HOME\Desktop\*.lnk" -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Users\Public\Desktop\*.lnk" -ErrorAction SilentlyContinue

    Write-Host "`n✅  Desktop icons removed.`n" -ForegroundColor Green
}

function flushCache {
    Write-Host "🧹 Removing Windows cache..." -ForegroundColor Yellow

    $paths = @(
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\Temp",
        "$env:TEMP",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    Write-Host "✅ Windows cache removed." -ForegroundColor Green
}

function flushDNS {
    Clear-DnsClientCache
    Write-Host "✅ DNS cache removed." -ForegroundColor Green
}

function Test-InternetConnection {
    try {
        Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Scoop Search
if ((Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&scoop-search --hook)
}

# See https://ch0.co/tab-completion for details.
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) { 
    Invoke-Expression (& { (zoxide init powershell | Out-String) }) 
}