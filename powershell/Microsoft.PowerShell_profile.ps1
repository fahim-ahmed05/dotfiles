# Aliases
Set-Alias -Name ls -Value eza
Set-Alias -Name cd -Value z -Option AllScope

# Prompt
oh-my-posh init pwsh --config "$env:USERPROFILE\GitHub\dotfiles\config\omp\robbyrussell_gruvbox.omp.json" | Invoke-Expression

# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode                      = 'Windows'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
        Command   = '#89b482'  # aqua
        Parameter = '#a9b665'  # green
        Operator  = '#e78a4e'  # orange
        Variable  = '#d3869b'  # purple
        String    = '#d8a657'  # yellow
        Number    = '#83a598'  # blue
        Type      = '#928374'  # gray
        Comment   = '#a89984'  # taupe
        Keyword   = '#d3869b'  # purple
        Error     = '#ea6962'  # red
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

function pwroff {
    shutdown /s /f /t 0
}

function reboot {
    shutdown /r /f /t 0
}

# Pipx
function pi {
    pipx install $args[0]
}

# Winget
function ws {
    $query = $args -join ' '
    Write-Host "`n🔍  Searching for '$query'...`n" -ForegroundColor Cyan
    winget search $query
}

function wi {
    winget install $args[0] --accept-package-agreements --accept-source-agreements
    Start-Sleep -Seconds 1.5

    rmDesktopIcons
}

function wu {
    Write-Host "`n📦  Updating winget sources...`n" -ForegroundColor Cyan
    winget source update

    Write-Host "`n📦  Updating winget packages...`n" -ForegroundColor Cyan
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Host "`n📦  Updating winget...`n" -ForegroundColor Cyan
    winget upgrade winget

    Write-Host "`n📦  Updating scoop packages...`n" -ForegroundColor Cyan
    scoop update
    scoop cleanup *

    Write-Host "`n📦  Updating pip...`n" -ForegroundColor Cyan
    python.exe -m pip install --upgrade pip

    Write-Host "`n📦  Updating pipx packages...`n" -ForegroundColor Cyan
    pipx upgrade-all

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
    Remove-Item $env:USERPROFILE\Desktop\*.lnk
    Remove-Item C:\Users\Public\Desktop\*.lnk 
    Write-Host "`n✅  Desktop icons removed.`n" -ForegroundColor Green
}

function flushCache {
    $paths = @(
        "$env:SystemRoot\Prefetch",
        "$env:SystemRoot\Temp",
        $env:TEMP,
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item "$path\*" -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    Write-Host "`n✅  Windows cache removed.`n" -ForegroundColor Green
}

function flushDNS {
    Clear-DnsClientCache
    Write-Host "`n✅  DNS cache removed.`n" -ForegroundColor Green
}

# Scoop Search
if ((Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&scoop-search --hook)
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) { 
    Invoke-Expression (& { (zoxide init powershell | Out-String) }) 
}