<#
.SYNOPSIS
Highly Optimized Interactive Audiobook Downloader using yt-dlp, fzf, and ffmpeg.
#>
param (
    [string]$OutDir = "$env:USERPROFILE\Music\Audiobooks",
    [string]$HistoryFile = "$env:USERPROFILE\Configs\audiobook-dl\history.json",
    [int]$ParallelLimit = 2
)

$ErrorActionPreference = "Stop"

# --- Globals & Encoding ---
chcp 65001 >$null
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
$global:utf8NoBom = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $global:utf8NoBom
[Console]::InputEncoding = $global:utf8NoBom
$OutputEncoding = $global:utf8NoBom

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
    }
    catch {}
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

function Get-BookDestPath ([hashtable]$Meta) {
    return Join-Path (Join-Path $OutDir (Get-SafeName $Meta.Author)) (Get-SafeName $Meta.Title)
}

function Get-TrackTitle ([hashtable]$Meta, [bool]$IsMulti, [int]$TrackNumber) {
    if ($IsMulti) { return "$($Meta.Title) - Part $("{0:D2}" -f $TrackNumber)" }
    return $Meta.Title
}

function Get-OutputFilePath ([string]$DestPath, [string]$BaseName) {
    return Join-Path $DestPath "$BaseName.m4a"
}

function Convert-ToYoutubeUrls ([string[]]$Items) {
    return @($Items | ForEach-Object { "https://youtu.be/" + (Format-CleanString ($_ -split '\|')[0]) })
}

function Convert-ToSelectionObjects ([string[]]$Items) {
    return @($Items | ForEach-Object {
            $parts = (Format-CleanString $_) -split '\|', 2
            [PSCustomObject]@{
                Url   = "https://youtu.be/$($parts[0])"
                Title = if ($parts.Count -gt 1) { $parts[1].Trim() } else { "" }
            }
        })
}

function Invoke-FzfSelect ([string[]]$Items, [string]$Prompt, [string]$Query = "") {
    return @($Items | fzf -m --delimiter="\|" --with-nth=2.. --print-query --query=$Query --prompt=$Prompt)
}

function Get-ExistingBookFolders ([string]$RootPath) {
    if (-not (Test-Path $RootPath)) { return @() }

    return @(
        Get-ChildItem -Path $RootPath -Directory | ForEach-Object {
            $author = $_
            Get-ChildItem -Path $author.FullName -Directory | ForEach-Object {
                [PSCustomObject]@{
                    Author  = $author.Name
                    Title   = $_.Name
                    Path    = $_.FullName
                    Display = "$($author.Name) / $($_.Name)"
                }
            }
        }
    )
}

function Invoke-SelectionLoop ([string[]]$Items, [string]$Prompt) {
    $lastQuery = ""

    while ($true) {
        $fzfOut = @(Invoke-FzfSelect -Items $Items -Prompt $Prompt -Query $lastQuery)
        if (-not $fzfOut -or $fzfOut.Count -le 1) { break }

        $lastQuery = $fzfOut[0]
        $selected = $fzfOut[1..($fzfOut.Count - 1)]
        $selections = Convert-ToSelectionObjects $selected
        Confirm-And-Process -Selections $selections
    }
}

function Update-History ([string]$Url, [string]$Name, [string]$Type) {
    $list = $global:Hist.$Type
    $existing = $list | Where-Object { $_.Url -eq $Url }
    
    if ($existing) {
        $existing.Count++
        $existing.Name = $Name
    }
    else {
        $newItem = [PSCustomObject]@{ Name = $Name; Url = $Url; Count = 1 }
        $list += $newItem
    }
    
    $global:Hist.$Type = @($list | Sort-Object Count -Descending | Select-Object -First 50)
    $jsonOut = $global:Hist | ConvertTo-Json -Depth 3 -Compress
    [System.IO.File]::WriteAllText($HistoryFile, $jsonOut, $global:utf8NoBom)
}

function Get-Metadata ($url, [string]$VideoTitle = "") {
    if ([string]::IsNullOrWhiteSpace($VideoTitle)) {
        Write-Host "`nFetching metadata..." -ForegroundColor DarkGray
        $meta = yt-dlp --encoding utf-8 --dump-json --no-warnings $url 2>$null | ConvertFrom-Json
        if (-not $meta) { throw "Failed to fetch data for $url" }
        $VideoTitle = $meta.title
    }

    Write-Host "`nFull Video Title: $VideoTitle" -ForegroundColor Green
    
    $Title = Read-Host "Enter Book Title"
    while ([string]::IsNullOrWhiteSpace($Title)) { $Title = Read-Host "Enter Book Title (Required)" }

    $Author = Read-Host "Enter Author Name"
    while ([string]::IsNullOrWhiteSpace($Author)) { $Author = Read-Host "Enter Author Name (Required)" }

    return @{ Title = Format-CleanString $Title; Author = Format-CleanString $Author }
}

function Write-AudioMetadata ([string]$FilePath, [hashtable]$Meta, [int]$TrackNumber) {
    if (-not (Test-Path $FilePath)) { throw "Expected audio file not found: $FilePath" }

    $tempFile = [IO.Path]::Combine(
        [IO.Path]::GetDirectoryName($FilePath),
        ([IO.Path]::GetFileNameWithoutExtension($FilePath) + ".metadata" + [IO.Path]::GetExtension($FilePath))
    )

    $ffmpegArgs = @(
        "-nostdin",
        "-loglevel", "error",
        "-y",
        "-i", $FilePath,
        "-map", "0",
        "-c", "copy",
        "-map_metadata", "0",
        "-metadata", "title=$($Meta.TrackTitle)",
        "-metadata", "album=$($Meta.Title)",
        "-metadata", "artist=$($Meta.Author)",
        "-metadata", "album_artist=$($Meta.Author)",
        "-metadata", "albumartist=$($Meta.Author)",
        "-metadata", "track=$TrackNumber",
        "-metadata", "track_number=$TrackNumber",
        $tempFile
    )

    $proc = Start-Process -FilePath "ffmpeg" -ArgumentList ($ffmpegArgs | ForEach-Object { '"{0}"' -f ($_ -replace '"', '\"') }) -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0 -or -not (Test-Path $tempFile)) { throw "ffmpeg failed while writing metadata for $FilePath" }

    Move-Item -Force $tempFile $FilePath
}

# --- Core Download & Processing Logic ---
function Update-TerminalLine ([int]$SlotIndex, [int]$TotalSlots, [object]$ConsoleLock, [string]$Content) {
    if ($null -eq $ConsoleLock -or $TotalSlots -le 0) { return }
    $e = [char]27
    $dist = $TotalSlots - $SlotIndex
    if ($dist -le 0) { return }

    [System.Threading.Monitor]::Enter($ConsoleLock)
    try {
        [Console]::Write("$e[${dist}A`r$e[2K$Content$e[${dist}B`r")
    }
    finally {
        [System.Threading.Monitor]::Exit($ConsoleLock)
    }
}

# --- Core Download & Processing Logic ---
function Invoke-Download (
    [string]$Url, 
    $Meta, 
    [bool]$IsMulti, 
    [int]$TrackNumber = 1, 
    [string]$DestPath,
    [int]$SlotIndex = 0,
    [int]$TotalSlots = 1,
    [object]$ConsoleLock = $null
) {
    $SafeTitle = Get-SafeName $Meta.Title

    if (-not (Test-Path $DestPath)) { New-Item -ItemType Directory -Path $DestPath | Out-Null }

    $trackTitle = Get-TrackTitle -Meta $Meta -IsMulti:$IsMulti -TrackNumber $TrackNumber
    $safeTrackTitle = Get-SafeName $trackTitle
    $titleDisplay = if ($IsMulti) { $trackTitle } else { $Meta.Title }

    # Truncate title for display if needed so line never wraps
    $winWidth = 80
    try { $winWidth = [Console]::WindowWidth } catch {}
    if ($winWidth -le 0) { $winWidth = 80 }
    $maxTitleLen = [Math]::Max(25, [Math]::Min(38, $winWidth - 42))
    $shortTitle = if ($titleDisplay.Length -gt $maxTitleLen) { $titleDisplay.Substring(0, $maxTitleLen - 3) + "..." } else { $titleDisplay }

    $e = [char]27
    $filledChar = [char]0x2588 # █
    $emptyChar  = [char]0x2591 # ░
    $barWidth   = 10

    $baseArgs = @(
        "--encoding", "utf-8",
        "--extract-audio", "--audio-format", "m4a", "--force-ipv4", 
        "--sponsorblock-remove", "sponsor,intro,outro,selfpromo,interaction",
        "--no-embed-chapters", "--embed-thumbnail", "--convert-thumbnails", "jpg",
        "--ppa", "ThumbnailsConvertor+ffmpeg_o:-vf crop='min(iw\,ih):min(iw\,ih)'",
        "--newline",
        "--no-warnings",
        "--progress-template", "download:PROGRESS:%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s|%(progress._total_bytes_str|progress._total_bytes_estimate_str)s"
    )

    $ytdlpArgs = [System.Collections.Generic.List[string]]::new()
    foreach ($arg in $baseArgs) { $ytdlpArgs.Add($arg) }

    $ytdlpArgs.Add("-P")
    $ytdlpArgs.Add($DestPath)

    $ytdlpArgs.Add("-o")
    if ($IsMulti) {
        $ytdlpArgs.Add("$safeTrackTitle.%(ext)s") 
    }
    else { 
        $ytdlpArgs.Add("$SafeTitle.%(ext)s") 
    }
    
    $ytdlpArgs.Add($Url)

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = "yt-dlp"
        foreach ($arg in $ytdlpArgs) {
            $psi.ArgumentList.Add($arg)
        }
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stderrTask = $proc.StandardError.ReadToEndAsync()

        $barEmpty = "$emptyChar" * $barWidth
        $initialContent = "$e[36m[DOWNLOADING]$e[0m [$e[34m$barEmpty$e[0m]   0%  $shortTitle  $e[90m(Connecting...)$e[0m"
        Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $initialContent

        $recentStdout = [System.Collections.Generic.List[string]]::new()

        while (-not $proc.StandardOutput.EndOfStream) {
            $line = $proc.StandardOutput.ReadLine()
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            $matched = $false
            $pctNum = 0.0
            $spd = ""
            $eta = ""

            # 1. yt-dlp custom template: PROGRESS: 45.0%| 2.4MiB/s|00:15| 10MiB
            if ($line -match '^PROGRESS:\s*(?<pct>[\d\.]+)%\|(?<spd>[^|]*)\|(?<eta>[^|]*)\|(?<tot>.*)$') {
                if ([double]::TryParse($matches['pct'], [ref]$pctNum)) {
                    $spd = $matches['spd'].Trim()
                    $eta = $matches['eta'].Trim()
                    $matched = $true
                }
            }
            # 2. aria2c external downloader: [#hex down/tot(pct%) CN:n DL:speed ETA:time]
            elseif ($line -match '\[#\w+\s+(?<down>[^\/\s]+)\/(?<tot>[^\(\s]+)(\((?<pct>\d+)%\))?(\s+CN:\d+)?(\s+DL:(?<spd>[^\s\]]+))?(\s+ETA:(?<eta>[^\]]+))?') {
                $rawPct = if ($matches['pct']) { $matches['pct'] } else { '0' }
                if ([double]::TryParse($rawPct, [ref]$pctNum)) {
                    $spdRaw = if ($matches['spd']) { $matches['spd'].Trim() } else { '' }
                    $spd = if ($spdRaw -and $spdRaw -notmatch '/s$') { "$spdRaw/s" } else { $spdRaw }
                    $eta = if ($matches['eta']) { $matches['eta'].Trim() } else { '' }
                    $matched = $true
                }
            }
            # 3. yt-dlp native fallback: [download]  45.0% of ... at 2.4MiB/s ETA 00:15
            elseif ($line -match '^\[download\]\s+(?<pct>[\d\.]+)%\s+of\s+.*?(?:\s+at\s+(?<spd>[^\s]+))?(?:\s+ETA\s+(?<eta>[^\s]+))?$') {
                if ([double]::TryParse($matches['pct'], [ref]$pctNum)) {
                    $spd = if ($matches['spd']) { $matches['spd'].Trim() } else { '' }
                    $eta = if ($matches['eta']) { $matches['eta'].Trim() } else { '' }
                    $matched = $true
                }
            }

            if ($matched) {
                # Throttle display updates to ~80ms intervals
                if ($sw.ElapsedMilliseconds -gt 80 -or $pctNum -ge 100.0) {
                    $sw.Restart()

                    $filled = [Math]::Max(0, [Math]::Min($barWidth, [int](($pctNum / 100.0) * $barWidth)))
                    $empty = $barWidth - $filled
                    $barStr = ("$filledChar" * $filled) + ("$emptyChar" * $empty)
                    $pctStr = "{0,3}%" -f [int]$pctNum

                    $info = if ($spd -and $spd -ne 'NA') { "$spd" } else { "" }
                    if ($eta -and $eta -ne 'NA') { $info += "  ETA $eta" }

                    $content = "$e[36m[DOWNLOADING]$e[0m [$e[34m$barStr$e[0m] $pctStr  $shortTitle  $e[90m$info$e[0m"
                    Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
                }
            }
            elseif ($line -match '^\[(ExtractAudio|ThumbnailsConvertor|EmbedThumbnail|ffmpeg|MoveFiles)\]') {
                if ($sw.ElapsedMilliseconds -gt 150) {
                    $sw.Restart()
                    $content = "$e[33m[PROCESSING]$e[0m  $shortTitle  $e[90m(Converting audio & embedding artwork...)$e[0m"
                    Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
                }
            }

            if ($recentStdout.Count -ge 20) { $recentStdout.RemoveAt(0) }
            $recentStdout.Add($line)
        }

        $proc.WaitForExit()
        $stderr = $stderrTask.GetAwaiter().GetResult()

        if ($proc.ExitCode -ne 0) {
            $content = "$e[31m[FAIL]$e[0m        $titleDisplay"
            Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
            if ($stderr) {
                Write-Host $stderr.Trim() -ForegroundColor DarkRed
            }
            elseif ($recentStdout.Count -gt 0) {
                Write-Host ($recentStdout -join "`n") -ForegroundColor DarkRed
            }
            return $false
        }

        $outputBaseName = if ($IsMulti) { $safeTrackTitle } else { $SafeTitle }
        $outputFile = Get-OutputFilePath -DestPath $DestPath -BaseName $outputBaseName
        
        if (-not (Test-Path $outputFile)) {
            $content = "$e[31m[FAIL]$e[0m        $titleDisplay (File not found)"
            Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
            return $false
        }

        $content = "$e[33m[PROCESSING]$e[0m  $shortTitle  $e[90m(Writing metadata...)$e[0m"
        Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content

        $metaToWrite = @{
            Title      = $Meta.Title
            Author     = $Meta.Author
            TrackTitle = $trackTitle
        }
        Write-AudioMetadata -FilePath $outputFile -Meta $metaToWrite -TrackNumber $TrackNumber

        # Final DONE line for this track
        $content = "$e[32m[DONE]$e[0m        $titleDisplay"
        Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
        return $true
    }
    catch {
        $content = "$e[31m[FAIL]$e[0m        $titleDisplay ($_)"
        Update-TerminalLine -SlotIndex $SlotIndex -TotalSlots $TotalSlots -ConsoleLock $ConsoleLock -Content $content
        return $false
    }
}

function Start-AudiobookDownload ([string[]]$Urls, [bool]$IsMulti, [string[]]$VideoTitles) {
    $downloadJobs = @()

    if (-not $IsMulti) {
        $index = 0
        foreach ($u in $Urls) {
            $videoTitle = if ($VideoTitles -and $index -lt $VideoTitles.Count) { $VideoTitles[$index] } else { "" }
            $meta = Get-Metadata $u -VideoTitle $videoTitle
            $destPath = Get-BookDestPath $meta
            $downloadJobs += [PSCustomObject]@{ Url = $u; Meta = $meta; DestPath = $destPath; TrackNum = 1; IsMulti = $false }
            $index++
        }
    }
    else {
        $appendChoice = Read-Host "`n[1] New Book`n[2] Append to Existing`nChoice"
        $startNum = 1
        $destPath = ""
        $meta = $null
        
        if ($appendChoice -eq '2') {
            $folders = Get-ExistingBookFolders $OutDir

            if ($folders.Count -eq 0) {
                Write-Host "No existing folders found. Treating as new book." -ForegroundColor Yellow
                $appendChoice = '1'
            }
            else {
                $fzfInput = $folders.Display
                $selectedDisplay = @($fzfInput | fzf --prompt="Select existing folder (ESC to cancel): ")
                if (-not $selectedDisplay) { return }
                
                $selected = $folders | Where-Object Display -eq $selectedDisplay[0]
                $destPath = $selected.Path
                $meta = @{ Author = $selected.Author; Title = $selected.Title }
                
                $startNum = (Get-ChildItem -Path $destPath -File).Count + 1
                Write-Host "Appending starting at Part $startNum" -ForegroundColor Green
            }
        } 
        
        if ($appendChoice -eq '1') {
            $videoTitle = if ($VideoTitles -and $VideoTitles.Count -gt 0) { $VideoTitles[0] } else { "" }
            $meta = Get-Metadata $Urls[0] -VideoTitle $videoTitle
            $destPath = Get-BookDestPath $meta
        }
        
        $trackNum = $startNum
        foreach ($u in $Urls) {
            $downloadJobs += [PSCustomObject]@{ Url = $u; Meta = $meta; DestPath = $destPath; TrackNum = $trackNum; IsMulti = $true }
            $trackNum++
        }
    }

    $scriptPath = $PSCommandPath
    $consoleLock = [object]::new()
    
    while ($downloadJobs.Count -gt 0) {
        $failedJobs = @()
        $totalSlots = $downloadJobs.Count
        
        # Attach SlotIndex to each job and print initial [START] lines
        $e = [char]27
        for ($i = 0; $i -lt $totalSlots; $i++) {
            $downloadJobs[$i] | Add-Member -NotePropertyName SlotIndex -NotePropertyValue $i -Force
            $titleDisp = if ($downloadJobs[$i].IsMulti) { 
                Get-TrackTitle -Meta $downloadJobs[$i].Meta -IsMulti:$downloadJobs[$i].IsMulti -TrackNumber $downloadJobs[$i].TrackNum 
            } else { 
                $downloadJobs[$i].Meta.Title 
            }
            [Console]::WriteLine("$e[90m[QUEUED]$e[0m      $titleDisp...")
        }
        
        $results = $downloadJobs | ForEach-Object -Parallel {
            . $using:scriptPath
            $success = Invoke-Download -Url $_.Url -Meta $_.Meta -IsMulti $_.IsMulti -TrackNumber $_.TrackNum -DestPath $_.DestPath -SlotIndex $_.SlotIndex -TotalSlots $using:totalSlots -ConsoleLock $using:consoleLock
            if (-not $success) { return $_ }
        } -ThrottleLimit $ParallelLimit
        
        if ($results) {
            $failedJobs = @($results)
        }

        if ($failedJobs.Count -gt 0) {
            Write-Host "`n=============================================" -ForegroundColor Red
            Write-Host "             FAILED DOWNLOADS                " -ForegroundColor Red
            Write-Host "=============================================" -ForegroundColor Red
            
            $fzfInput = @()
            for ($i = 0; $i -lt $failedJobs.Count; $i++) {
                $fj = $failedJobs[$i]
                $titleDisplay = if ($fj.IsMulti) { Get-TrackTitle -Meta $fj.Meta -IsMulti:$fj.IsMulti -TrackNumber $fj.TrackNum } else { $fj.Meta.Title }
                $fzfInput += "$i|$titleDisplay - $($fj.Url)"
            }
            
            $fzfOut = @($fzfInput | fzf -m --delimiter="\|" --with-nth=2.. --prompt="Select jobs to retry (TAB: multi, ESC: continue)> ")
            
            if (-not $fzfOut -or $fzfOut.Count -eq 0) {
                break
            }
            
            $downloadJobs = @()
            foreach ($selection in $fzfOut) {
                $idx = [int]($selection -split '\|')[0]
                $downloadJobs += $failedJobs[$idx]
            }
        }
        else {
            Write-Host "`nFinished: All parts downloaded and tagged successfully.`n" -ForegroundColor Green
            break
        }
    }
}
function Confirm-And-Process ([object[]]$Selections) {
    if (-not $Selections) { return }
    $Urls = @($Selections | ForEach-Object { $_.Url })
    $VideoTitles = @($Selections | ForEach-Object { $_.Title })
    $prompt = if ($Urls.Count -eq 1) { "`nIs this [1] A Single Book or [2] Part of a Multi-part Book? (1/2)" } 
    else { "`nAre these [1] Multiple Single Books or [2] Parts of ONE Book? (1/2)" }
    $q = Read-Host $prompt
    Start-AudiobookDownload -Urls $Urls -VideoTitles $VideoTitles -IsMulti ($q -eq '2')
}

function Invoke-PlaylistMenu ([switch]$IsChannel) {
    $Type = if ($IsChannel) { "Channels" } else { "Playlists" }

    Write-Host "`nSelect from history or paste a new $Type URL" -ForegroundColor Yellow
    $historyItems = $global:Hist.$Type
    $fzfInput = $historyItems | ForEach-Object { "$($_.Name) | $($_.Url)" }
    
    $fzfOut = @($fzfInput | fzf --print-query --prompt="$Type URL (ESC to go back)> ")
    
    $rawSelection = if ($fzfOut.Count -gt 1) { $fzfOut[1] } elseif ($fzfOut.Count -gt 0) { $fzfOut[0] } else { "" }
    $rawSelection = Format-CleanString $rawSelection
    
    if (-not $rawSelection) { return }
    
    $targetUrl = if ($rawSelection -match " \| (https?://.+)$") { $matches[1] } else { $rawSelection }
    $targetUrl = $targetUrl -replace '/(videos|featured|shorts|streams|playlists)/?$', ''

    Write-Host "`nFetching list..." -ForegroundColor DarkGray
    
    $rawCache = @(yt-dlp --encoding utf-8 --flat-playlist --print "%(playlist_title|channel|uploader)s:::%(id)s|%(title)s" $targetUrl)
    
    if (-not $rawCache -or $rawCache.Count -eq 0) { 
        Write-Host "Failed to fetch videos or list is empty." -ForegroundColor Red
        return 
    }

    # Scrub " - Videos" (case insensitive, flexible spacing) from the target name before saving
    $targetName = ($rawCache[0] -split ':::', 2)[0] -replace '(?i)\s*-\s*videos$', ''
    Update-History -Url $targetUrl -Name $targetName -Type $Type

    $playlistCache = $rawCache | ForEach-Object { ($_ -split ':::', 2)[1] }

    if ($IsChannel) {
        Invoke-SelectionLoop -Items $playlistCache -Prompt "Select videos (TAB: multi, ESC: Main Menu)> "
    }
    else {
        $dlType = Read-Host "`n[1] Download All ($($playlistCache.Count) videos)`n[2] Select specific videos (fzf)`nChoice"
        if ($dlType -eq '1') {
            $selections = Convert-ToSelectionObjects $playlistCache
            Confirm-And-Process -Selections $selections
        }
        elseif ($dlType -eq '2') {
            Invoke-SelectionLoop -Items $playlistCache -Prompt "Select videos (TAB: multi, ESC: Main Menu)> "
        }
    }
}

# --- Main Application Loop ---
function Start-InteractiveMode {
    while ($true) {
        Write-Host "`n=============================================" -ForegroundColor Cyan
        Write-Host "      Interactive Audiobook Downloader       " -ForegroundColor Cyan
        Write-Host "=============================================" -ForegroundColor Cyan
        
        $mode = Read-Host "`n[1] Single`n[2] Multi`n[3] Channel (fzf)`n[4] Playlist (fzf)`n`nSelect mode (Enter to exit)"

        if ([string]::IsNullOrWhiteSpace($mode)) { break }

        if ($mode -eq '1') { 
            $urlInput = Read-Host "URL"
            if ($urlInput) { Start-AudiobookDownload -Urls @($urlInput) -IsMulti:$false }

        }
        elseif ($mode -eq '2') { 
            $urlInput = Read-Host "URLs (space-separated)"
            $urls = @($urlInput -split '\s+' | Where-Object { $_ })
            if ($urls) { Start-AudiobookDownload -Urls $urls -IsMulti:$true }

        }
        elseif ($mode -eq '3') {
            Invoke-PlaylistMenu -IsChannel

        }
        elseif ($mode -eq '4') {
            Invoke-PlaylistMenu

        }
        else { 
            Write-Host "Invalid mode." -ForegroundColor Red
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Start-InteractiveMode
}
