# Aliases
Set-Alias -Name ls -Value eza
Set-Alias -Name cd -Value z -Option AllScope

# Prompt
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\robbyrussell.omp.json" | Invoke-Expression

# PSReadLine
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

Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

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

function su { 
    Start-Process wt -Verb RunAs -ArgumentList @(
        "--profile", $env:WT_PROFILE_ID,
        "-d", (Get-Location).Path
    )
}

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
    Write-Host "📦 Updating winget packages..." -ForegroundColor Cyan
    try {
        winget source update
        winget upgrade --all --accept-package-agreements --accept-source-agreements
    }
    catch {
        Write-Host "❌ Winget update failed." -ForegroundColor Red
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "📦 Updating scoop packages..." -ForegroundColor Cyan
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
        Write-Host "🐍 Updating pip..." -ForegroundColor Cyan
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
        Write-Host "📦 Updating pipx packages..." -ForegroundColor Cyan
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

    if(Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "📦 Updating Chocolatey packages..." -ForegroundColor Cyan
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

    if (Get-Command rmDesktopIcons -ErrorAction SilentlyContinue) {
        rmDesktopIcons
    }
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
        Write-Output $url
    }
    catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

function rmDesktopIcons {
    $desktopPaths = @(
        "$HOME\Desktop",
        "C:\Users\Public\Desktop"
    )

    foreach ($path in $desktopPaths) {
        if (Test-Path $path) {
            Remove-Item -Path "$path\*.lnk" -Force -Recurse -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "📂 Not found: $path" -ForegroundColor DarkGray
        }
    }

    Write-Host "✅ Desktop icons removed." -ForegroundColor Green
}

function flushCache {
    Write-Host "🧹 Removing Windows cache..." -ForegroundColor Yellow

    $paths = @(
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\Temp",
        "$env:TEMP"
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

function syncMusic {
    $current = Get-Location
    Set-Location "$HOME\Music\YouTube Music"
    spotdl sync "$HOME\.spotdl\music.sync.spotdl"
    Set-Location -Path $current
}

# Scoop Search
Invoke-Expression (&scoop-search --hook)

# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })