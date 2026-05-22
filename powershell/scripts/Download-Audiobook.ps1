<#
.SYNOPSIS
Lean Interactive Audiobook Downloader using yt-dlp, fzf, and ffmpeg.
#>
param (
    [Parameter(Position = 0)]
    [string]$OutDir = "$env:USERPROFILE\Music\Audiobooks"
)

$ErrorActionPreference = "Stop"

# FIX: Force all Console and Pipeline text to be strictly UTF-8 WITHOUT BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $utf8NoBom
[Console]::InputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

# --- Dependencies Check ---
foreach ($dep in "yt-dlp", "ffmpeg", "fzf") {
    if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) { throw "`n[ERROR] $dep is missing from PATH." }
}

# --- Directory Setup ---
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$HistoryFile = "$env:USERPROFILE\Configs\audiobook-dl\channels.json"
$HistoryDir = Split-Path $HistoryFile
if (-not (Test-Path $HistoryDir)) { New-Item -ItemType Directory -Path $HistoryDir | Out-Null }

# --- Core Logic ---
function Get-SafeName ($name) {
    $regex = "[{0}]" -f [Regex]::Escape(([IO.Path]::GetInvalidFileNameChars() -join ''))
    return ($name -replace $regex, '_').Trim()
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

    return @{ Title = $Title.Trim(" `t`n`r$([char]0xFEFF)"); Author = $Author.Trim(" `t`n`r$([char]0xFEFF)") }
}

function Invoke-Download ([string[]]$Urls, $Meta, [switch]$IsMulti, [int]$StartNum = 1, [string]$DestPath) {
    $SafeTitle = $Meta.Title.Replace('\', '\\')
    $SafeAuthor = $Meta.Author.Replace('\', '\\')

    $trackNum = $StartNum

    foreach ($url in $Urls) {
        $ytdlpArgs = @(
            "--extract-audio", "--audio-format", "opus",
            "--force-ipv4", 
            "--sponsorblock-remove", "sponsor,intro,outro,selfpromo,interaction",
            "--embed-metadata", "--embed-thumbnail",
            
            "--parse-metadata", "title:%(album)s",
            "--parse-metadata", "title:%(artist)s",
            "--parse-metadata", "title:%(album_artist)s",
            "--parse-metadata", "title:%(track_number)s",
            
            "--replace-in-metadata", "album", "^.*$", $SafeTitle,
            "--replace-in-metadata", "artist", "^.*$", $SafeAuthor,
            "--replace-in-metadata", "album_artist", "^.*$", $SafeAuthor,
            "--replace-in-metadata", "title", "^.*$", $SafeTitle,
            "--replace-in-metadata", "track_number", "^.*$", "$trackNum",
            
            "--ppa", "ThumbnailsConvertor+ffmpeg_o:-vf crop='min(iw\,ih):min(iw\,ih)'"
        )

        if ($IsMulti) {
            $ytdlpArgs += "-o", "$DestPath/Part $("{0:D2}" -f $trackNum).%(ext)s"
        }
        else {
            $ytdlpArgs += "-o", "$DestPath.%(ext)s"
        }

        $ytdlpArgs += $url

        if ($IsMulti) { Write-Host "`nDownloading Part $trackNum..." -ForegroundColor Cyan } 
        else { Write-Host "`nDownloading..." -ForegroundColor Cyan }
        
        & yt-dlp $ytdlpArgs

        $trackNum++
    }
}

function Process-Downloads ([string[]]$UrlsToProcess, [string]$CurrentMode) {
    $isMulti = $false
    if ($CurrentMode -eq '2') {
        $isMulti = $true
    }
    elseif ($CurrentMode -eq '3') {
        if ($UrlsToProcess.Count -eq 1) {
            $q = Read-Host "`nIs this [1] A Single Book or [2] Part of a Multi-part Book? (1/2)"
            $isMulti = ($q -eq '2')
        }
        else {
            $q = Read-Host "`nAre these [1] Multiple Single Books or [2] Parts of ONE Book? (1/2)"
            $isMulti = ($q -eq '2')
        }
    }

    if (-not $isMulti) {
        foreach ($u in $UrlsToProcess) {
            $meta = Get-Metadata $u
            $outPath = Join-Path $OutDir "$(Get-SafeName $meta.Author) - $(Get-SafeName $meta.Title)"
            Invoke-Download -Urls @($u) -Meta $meta -DestPath $outPath
        }
    }
    else {
        $appendChoice = Read-Host "`n[1] New Book`n[2] Append to Existing`nChoice"
        $startNum = 1
        $destPath = ""
        $meta = $null
        
        if ($appendChoice -eq '2') {
            $folders = @(Get-ChildItem -Path $OutDir -Directory)
            
            if ($folders.Count -eq 0) {
                Write-Host "No existing folders found. Treating as new book." -ForegroundColor Yellow
                $appendChoice = '1'
            }
            else {
                $selectedFolder = @($folders.Name | fzf --prompt="Select existing folder (ESC to cancel): ")
                if (-not $selectedFolder -or $selectedFolder.Count -eq 0) { return }
                
                # FIX: Strip out invisible characters from fzf output
                $cleanFolderName = $selectedFolder[0].Trim(" `t`n`r$([char]0xFEFF)")
                
                $destPath = Join-Path $OutDir $cleanFolderName
                $meta = @{ Author = ($cleanFolderName -split " - ")[0]; Title = $cleanFolderName -replace "^.*?\s-\s", "" }
                $startNum = (Get-ChildItem -Path $destPath -File).Count + 1
                Write-Host "Appending starting at Part $startNum" -ForegroundColor Green
            }
        } 
        
        if ($appendChoice -eq '1') {
            $meta = Get-Metadata $UrlsToProcess[0]
            $destPath = Join-Path $OutDir "$(Get-SafeName $meta.Author) - $(Get-SafeName $meta.Title)"
        }
        
        Invoke-Download -Urls $UrlsToProcess -Meta $meta -IsMulti -StartNum $startNum -DestPath $destPath
    }
}

# --- Main Application Loop ---
while ($true) {
    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host "      Interactive Audiobook Downloader       " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    $mode = Read-Host "`n[1] Single`n[2] Multi`n[3] Channel (fzf)`n[0] Exit`nSelect mode"

    if ($mode -eq '0' -or [string]::IsNullOrWhiteSpace($mode)) { break }

    if ($mode -eq '1') { 
        $urlInput = Read-Host "URL"
        if (-not $urlInput) { continue }
        Process-Downloads -UrlsToProcess @($urlInput) -CurrentMode $mode

    }
    elseif ($mode -eq '2') { 
        $urlInput = Read-Host "URLs (space-separated)"
        $urls = @($urlInput -split '\s+' | Where-Object { $_ })
        if ($urls.Count -eq 0) { continue }
        Process-Downloads -UrlsToProcess $urls -CurrentMode $mode

    }
    elseif ($mode -eq '3') {
        $history = @()
        if (Test-Path $HistoryFile) { $history = @(Get-Content $HistoryFile | ConvertFrom-Json) }

        Write-Host "`nSelect from history or paste a new Channel URL" -ForegroundColor Yellow
        $fzfOut = @($history | fzf --print-query --prompt="Channel URL (ESC to go back)> ")
        
        $channelUrl = ""
        if ($fzfOut.Count -gt 1) { 
            $channelUrl = $fzfOut[1] 
        }
        elseif ($fzfOut.Count -gt 0) { 
            $channelUrl = $fzfOut[0] 
        }
        
        $channelUrl = $channelUrl.Trim(" `t`n`r$([char]0xFEFF)")
        if (-not $channelUrl) { continue }

        $channelUrl = $channelUrl -replace '/(videos|featured|shorts|streams|playlists)/?$', ''

        if ($channelUrl -notin $history) {
            $history = @($channelUrl) + $history
            $uniqueHistory = @($history | Select-Object -Unique)
            
            $jsonOut = if ($uniqueHistory.Count -eq 1) { "[`"$($uniqueHistory[0])`"]" } else { $uniqueHistory | ConvertTo-Json -Compress }
            [System.IO.File]::WriteAllText($HistoryFile, $jsonOut, $utf8NoBom)
        }

        Write-Host "`nFetching channel list (this happens once per channel)..." -ForegroundColor DarkGray
        
        $playlistCache = @(yt-dlp --flat-playlist --print "%(id)s|%(title)s" $channelUrl)
        
        if (-not $playlistCache -or $playlistCache.Count -eq 0) { 
            Write-Host "Failed to fetch videos or channel is empty." -ForegroundColor Red
            continue 
        }

        while ($true) {
            $selected = @($playlistCache | fzf -m --delimiter="\|" --with-nth=2.. --prompt="Select videos (TAB: multi, ESC: Main Menu)> ")
            
            if (-not $selected -or $selected.Count -eq 0) { break }
            
            $urls = @($selected | ForEach-Object { 
                    $id = ($_ -split '\|')[0].Trim(" `t`n`r$([char]0xFEFF)")
                    "https://youtu.be/$id"
                })
            
            Process-Downloads -UrlsToProcess $urls -CurrentMode $mode
            
            Write-Host "`nDownload complete. Returning to channel video list..." -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
        }
        
    }
    else { 
        Write-Host "Invalid mode." -ForegroundColor Red
    }
}