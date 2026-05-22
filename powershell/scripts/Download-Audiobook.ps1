<#
.SYNOPSIS
Highly Optimized Interactive Audiobook Downloader using yt-dlp, fzf, and ffmpeg.
#>
param ([string]$OutDir = "$env:USERPROFILE\Music\Audiobooks")

$ErrorActionPreference = "Stop"

# --- Globals & Encoding ---
$global:utf8NoBom = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $global:utf8NoBom
[Console]::InputEncoding  = $global:utf8NoBom
$OutputEncoding           = $global:utf8NoBom

$HistoryFile = "$env:USERPROFILE\Configs\audiobook-dl\history.json"
if (-not (Test-Path (Split-Path $HistoryFile))) { New-Item -ItemType Directory -Path (Split-Path $HistoryFile) | Out-Null }
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# --- Load History ---
$global:Hist = @{ Channels = @(); Playlists = @() }
if (Test-Path $HistoryFile) {
    try {
        $parsed = Get-Content $HistoryFile -Raw | ConvertFrom-Json
        if ($parsed -is [System.Management.Automation.PSCustomObject]) {
            if ($null -ne $parsed.Channels) { $global:Hist.Channels = @($parsed.Channels) }
            if ($null -ne $parsed.Playlists) { $global:Hist.Playlists = @($parsed.Playlists) }
        }
    } catch {}
}

# --- Dependencies Check ---
foreach ($dep in "yt-dlp", "ffmpeg", "fzf") {
    if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) { throw "`n[ERROR] $dep is missing from PATH." }
}

# --- Helper Functions ---
function Format-CleanString ([string]$str) { return $str.Trim(" `t`n`r$([char]0xFEFF)") }

function Get-SafeName ([string]$name) {
    $regex = "[{0}]" -f [Regex]::Escape(([IO.Path]::GetInvalidFileNameChars() -join ''))
    return ($name -replace $regex, '_').Trim()
}

function Update-History ([string]$Url, [string]$Name, [string]$Type) {
    $list = $global:Hist.$Type
    $existing = $list | Where-Object { $_.Url -eq $Url }
    
    if ($existing) {
        $existing.Count++
        $existing.Name = $Name
    } else {
        $newItem = [PSCustomObject]@{ Name = $Name; Url = $Url; Count = 1 }
        $list += $newItem
    }
    
    $global:Hist.$Type = @($list | Sort-Object Count -Descending | Select-Object -First 50)
    $jsonOut = $global:Hist | ConvertTo-Json -Depth 3 -Compress
    [System.IO.File]::WriteAllText($HistoryFile, $jsonOut, $global:utf8NoBom)
}

function Get-Metadata ($url) {
    Write-Host "`nFetching metadata..." -ForegroundColor DarkGray
    $meta = yt-dlp --dump-json --no-warnings $url 2>$null | ConvertFrom-Json
    if (-not $meta) { throw "Failed to fetch data for $url" }

    Write-Host "`nFull Video Title: $($meta.title)" -ForegroundColor Green
    
    $Title = Read-Host "Enter Book Title"
    while ([string]::IsNullOrWhiteSpace($Title)) { $Title = Read-Host "Enter Book Title (Required)" }

    $Author = Read-Host "Enter Author Name"
    while ([string]::IsNullOrWhiteSpace($Author)) { $Author = Read-Host "Enter Author Name (Required)" }

    return @{ Title = Format-CleanString $Title; Author = Format-CleanString $Author }
}

# --- Core Download & Processing Logic ---
function Invoke-Download ([string[]]$Urls, $Meta, [bool]$IsMulti, [int]$StartNum = 1, [string]$DestPath) {
    $SafeTitle = $Meta.Title.Replace('\', '\\')
    $SafeAuthor = $Meta.Author.Replace('\', '\\')

    $baseArgs = @(
        "--extract-audio", "--audio-format", "opus", "--force-ipv4", 
        "--sponsorblock-remove", "sponsor,intro,outro,selfpromo,interaction",
        "--embed-metadata", "--embed-thumbnail",
        "--parse-metadata", "title:%(album)s", "--parse-metadata", "title:%(artist)s",
        "--parse-metadata", "title:%(album_artist)s", "--parse-metadata", "title:%(track_number)s",
        "--replace-in-metadata", "album", "^.*$", $SafeTitle,
        "--replace-in-metadata", "artist", "^.*$", $SafeAuthor,
        "--replace-in-metadata", "album_artist", "^.*$", $SafeAuthor,
        "--replace-in-metadata", "title", "^.*$", $SafeTitle,
        "--ppa", "ThumbnailsConvertor+ffmpeg_o:-vf crop='min(iw\,ih):min(iw\,ih)'"
    )

    $trackNum = $StartNum
    foreach ($url in $Urls) {
        $ytdlpArgs = $baseArgs + "--replace-in-metadata", "track_number", "^.*$", "$trackNum"
        
        if ($IsMulti) { 
            $ytdlpArgs += "-o", "$DestPath/Part $("{0:D2}" -f $trackNum).%(ext)s" 
        } else { 
            $ytdlpArgs += "-o", "$DestPath.%(ext)s" 
        }
        
        $ytdlpArgs += $url

        # Fixed parsing issue by breaking the ternary operator out of the string
        $statusMsg = if ($IsMulti) { "`nDownloading Part $trackNum..." } else { "`nDownloading..." }
        Write-Host $statusMsg -ForegroundColor Cyan
        
        & yt-dlp $ytdlpArgs
        $trackNum++
    }
}

function Start-AudiobookDownload ([string[]]$Urls, [bool]$IsMulti) {
    if (-not $IsMulti) {
        foreach ($u in $Urls) {
            $meta = Get-Metadata $u
            $outPath = Join-Path $OutDir "$(Get-SafeName $meta.Author) - $(Get-SafeName $meta.Title)"
            Invoke-Download -Urls @($u) -Meta $meta -IsMulti:$false -DestPath $outPath
        }
        return
    }

    $appendChoice = Read-Host "`n[1] New Book`n[2] Append to Existing`nChoice"
    $startNum = 1
    $destPath = ""
    $meta = $null
    
    if ($appendChoice -eq '2') {
        $folders = @(Get-ChildItem -Path $OutDir -Directory)
        if ($folders.Count -eq 0) {
            Write-Host "No existing folders found. Treating as new book." -ForegroundColor Yellow
            $appendChoice = '1'
        } else {
            $selectedFolder = @($folders.Name | fzf --prompt="Select existing folder (ESC to cancel): ")
            if (-not $selectedFolder) { return }
            
            $cleanName = Format-CleanString $selectedFolder[0]
            $destPath = Join-Path $OutDir $cleanName
            $meta = @{ Author = ($cleanName -split " - ")[0]; Title = $cleanName -replace "^.*?\s-\s", "" }
            $startNum = (Get-ChildItem -Path $destPath -File).Count + 1
            Write-Host "Appending starting at Part $startNum" -ForegroundColor Green
        }
    } 
    
    if ($appendChoice -eq '1') {
        $meta = Get-Metadata $Urls[0]
        $destPath = Join-Path $OutDir "$(Get-SafeName $meta.Author) - $(Get-SafeName $meta.Title)"
    }
    
    Invoke-Download -Urls $Urls -Meta $meta -IsMulti:$true -StartNum $startNum -DestPath $destPath
}

function Confirm-And-Process ([string[]]$Urls) {
    if (-not $Urls) { return }
    $prompt = if ($Urls.Count -eq 1) { "`nIs this [1] A Single Book or [2] Part of a Multi-part Book? (1/2)" } 
              else { "`nAre these [1] Multiple Single Books or [2] Parts of ONE Book? (1/2)" }
    $q = Read-Host $prompt
    Start-AudiobookDownload -Urls $Urls -IsMulti ($q -eq '2')
}

function Invoke-PlaylistMenu ([switch]$IsChannel) {
    $Type = $IsChannel ? "Channels" : "Playlists"

    Write-Host "`nSelect from history or paste a new $Type URL" -ForegroundColor Yellow
    $historyItems = $global:Hist.$Type
    $fzfInput = $historyItems | ForEach-Object { "$($_.Name) | $($_.Url)" }
    
    $fzfOut = @($fzfInput | fzf --print-query --prompt="$Type URL (ESC to go back)> ")
    
    $rawSelection = Format-CleanString (if ($fzfOut.Count -gt 1) { $fzfOut[1] } elseif ($fzfOut.Count -gt 0) { $fzfOut[0] } else { "" })
    if (-not $rawSelection) { return }
    
    $targetUrl = if ($rawSelection -match " \| (https?://.+)$") { $matches[1] } else { $rawSelection }
    $targetUrl = $targetUrl -replace '/(videos|featured|shorts|streams|playlists)/?$', ''

    Write-Host "`nFetching list..." -ForegroundColor DarkGray
    
    $rawCache = @(yt-dlp --flat-playlist --print "%(playlist_title|channel|uploader)s:::%(id)s|%(title)s" $targetUrl)
    
    if (-not $rawCache -or $rawCache.Count -eq 0) { 
        Write-Host "Failed to fetch videos or list is empty." -ForegroundColor Red
        return 
    }

    $targetName = ($rawCache[0] -split ':::', 2)[0]
    Update-History -Url $targetUrl -Name $targetName -Type $Type

    $playlistCache = $rawCache | ForEach-Object { ($_ -split ':::', 2)[1] }

    if ($IsChannel) {
        while ($true) {
            $selected = @($playlistCache | fzf -m --delimiter="\|" --with-nth=2.. --prompt="Select videos (TAB: multi, ESC: Main Menu)> ")
            if (-not $selected -or $selected.Count -eq 0) { break }
            
            $urls = @($selected | ForEach-Object { "https://youtu.be/" + (Format-CleanString ($_ -split '\|')[0]) })
            Confirm-And-Process -Urls $urls
        }
    } else {
        $dlType = Read-Host "`n[1] Download All ($($playlistCache.Count) videos)`n[2] Select specific videos (fzf)`nChoice"
        $selected = if ($dlType -eq '1') { $playlistCache } 
                    elseif ($dlType -eq '2') { @($playlistCache | fzf -m --delimiter="\|" --with-nth=2.. --prompt="Select videos (TAB: multi, ESC: Main Menu)> ") }
        
        if ($selected -and $selected.Count -gt 0) {
            $urls = @($selected | ForEach-Object { "https://youtu.be/" + (Format-CleanString ($_ -split '\|')[0]) })
            Confirm-And-Process -Urls $urls
        }
    }
}

# --- Main Application Loop ---
while ($true) {
    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host "      Interactive Audiobook Downloader       " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    $mode = Read-Host "`n[1] Single`n[2] Multi`n[3] Channel (fzf)`n[4] Playlist (fzf)`n[ENTER] Exit`nSelect mode"

    if ([string]::IsNullOrWhiteSpace($mode)) { break }

    if ($mode -eq '1') { 
        $urlInput = Read-Host "URL"
        if ($urlInput) { Start-AudiobookDownload -Urls @($urlInput) -IsMulti:$false }

    } elseif ($mode -eq '2') { 
        $urlInput = Read-Host "URLs (space-separated)"
        $urls = @($urlInput -split '\s+' | Where-Object { $_ })
        if ($urls) { Start-AudiobookDownload -Urls $urls -IsMulti:$true }

    } elseif ($mode -eq '3') {
        Invoke-PlaylistMenu -IsChannel

    } elseif ($mode -eq '4') {
        Invoke-PlaylistMenu

    } else { 
        Write-Host "Invalid mode." -ForegroundColor Red
    }
}