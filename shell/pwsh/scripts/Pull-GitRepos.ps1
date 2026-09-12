<#
.SYNOPSIS
    Pulls updates for Git repositories based on a JSON configuration file or auto-discovery.

.DESCRIPTION
    Discovers Git repositories from machine-specific configs (e.g. git_repos_acer.json,
    git_repos_gigabyte.json) or falls back to common directories like $env:USERPROFILE\Git.
    Performs fast, safe parallel pulls with git pull --rebase, safely skipping repositories
    with uncommitted changes (dirty worktree) or no upstream remote tracking branch.

.PARAMETER ConfigPath
    Optional path to the JSON configuration file.
    If omitted, resolves machine config automatically or defaults to scanning $env:USERPROFILE\Git.

.PARAMETER Parallel
    Number of parallel Git pull operations. Default is 4.

.PARAMETER FetchOnly
    Only fetches remote refs without rebasing.

.PARAMETER DryRun
    Scans and checks status without pulling.

.EXAMPLE
    .\Pull-GitRepos.ps1

.EXAMPLE
    .\Pull-GitRepos.ps1 -Parallel 6

.EXAMPLE
    .\Pull-GitRepos.ps1 -ConfigPath "..\configs\git_repos_acer.json"
#>

param (
    [string]$ConfigPath = "",
    [int]$Parallel = 4,
    [switch]$FetchOnly,
    [switch]$DryRun
)

function Show-SummaryCard {
    param(
        [string]$Title,
        [string]$Message,
        [string]$BorderColor = "212"
    )
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        gum style --border normal --border-foreground $BorderColor --padding "0 2" --margin "1 0" "$Title`n$Message"
    }
    else {
        Write-Host "`n=== $Title ===" -ForegroundColor Cyan
        Write-Host $Message
    }
}

# 1. Resolve Configuration File
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $comp = if ($global:computer) { $global:computer } else { $env:COMPUTERNAME.ToLowerInvariant() }
    $configCandidates = @(
        (Join-Path $PSScriptRoot "..\configs\git_repos_$comp.json"),
        (Join-Path $PSScriptRoot "..\configs\git_repos.json")
    )
    foreach ($candidate in $configCandidates) {
        if (Test-Path $candidate) {
            $ConfigPath = $candidate
            break
        }
    }
}

# 2. Collect Candidate Repositories
$repoPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

if (-not [string]::IsNullOrWhiteSpace($ConfigPath) -and (Test-Path $ConfigPath)) {
    Write-Host "[*] Using config: $ConfigPath" -ForegroundColor DarkGray
    try {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if ($config.repos) {
            foreach ($repo in $config.repos) {
                $expanded = [System.Environment]::ExpandEnvironmentVariables($repo)
                if (Test-Path $expanded) {
                    [void]$repoPaths.Add([System.IO.Path]::GetFullPath($expanded))
                }
            }
        }
        if ($config.folders) {
            foreach ($folder in $config.folders) {
                $expanded = [System.Environment]::ExpandEnvironmentVariables($folder)
                if (Test-Path $expanded) {
                    Get-ChildItem -Path $expanded -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                        [void]$repoPaths.Add([System.IO.Path]::GetFullPath($_.FullName))
                    }
                }
            }
        }
    }
    catch {
        Write-Host "[-] Failed to read config file: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    # Default fallback: auto-discover repositories in $env:USERPROFILE\Git
    $defaultGitDir = Join-Path $env:USERPROFILE "Git"
    if (Test-Path $defaultGitDir) {
        Write-Host "[*] Auto-discovering repositories in $defaultGitDir..." -ForegroundColor DarkGray
        Get-ChildItem -Path $defaultGitDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            [void]$repoPaths.Add([System.IO.Path]::GetFullPath($_.FullName))
        }
    }
}

# 3. Filter Valid Git Repositories
$validRepos = @($repoPaths | Where-Object { Test-Path (Join-Path $_ ".git") } | Sort-Object)

if ($validRepos.Count -eq 0) {
    Write-Host "[-] No Git repositories found to update." -ForegroundColor Yellow
    exit 0
}

Write-Host "[*] Found $($validRepos.Count) Git repositories. Syncing (Parallel: $Parallel)..." -ForegroundColor Cyan

# 4. Perform Sync
$results = $validRepos | ForEach-Object -Parallel {
    $repo = $_
    $name = Split-Path $repo -Leaf
    $isFetchOnly = $using:FetchOnly
    $isDryRun = $using:DryRun

    Push-Location $repo
    try {
        # Check dirty working tree
        $status = git status --porcelain 2>$null
        if ($status) {
            return [PSCustomObject]@{
                Path    = $repo
                Name    = $name
                Status  = "Skipped (Dirty)"
                Details = "Working directory has uncommitted changes"
            }
        }

        # Check upstream branch
        $null = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
        if ($LASTEXITCODE -ne 0) {
            return [PSCustomObject]@{
                Path    = $repo
                Name    = $name
                Status  = "Skipped (No Upstream)"
                Details = "No remote tracking branch configured"
            }
        }

        if ($isDryRun) {
            return [PSCustomObject]@{
                Path    = $repo
                Name    = $name
                Status  = "DryRun"
                Details = "Ready to pull"
            }
        }

        if ($isFetchOnly) {
            $fetchOut = git fetch --prune 2>&1
            if ($LASTEXITCODE -eq 0) {
                return [PSCustomObject]@{
                    Path    = $repo
                    Name    = $name
                    Status  = "Fetched"
                    Details = ($fetchOut -join "`n").Trim()
                }
            }
            else {
                return [PSCustomObject]@{
                    Path    = $repo
                    Name    = $name
                    Status  = "Failed"
                    Details = ($fetchOut -join "`n").Trim()
                }
            }
        }

        # git pull --rebase
        $pullOut = git pull --rebase 2>&1
        if ($LASTEXITCODE -eq 0) {
            $outText = ($pullOut -join "`n").Trim()
            $statusLabel = if ($outText -match "Already up to date|Current branch .* is up to date") {
                "Up-to-date"
            } else {
                "Updated"
            }
            return [PSCustomObject]@{
                Path    = $repo
                Name    = $name
                Status  = $statusLabel
                Details = $outText
            }
        }
        else {
            return [PSCustomObject]@{
                Path    = $repo
                Name    = $name
                Status  = "Failed"
                Details = ($pullOut -join "`n").Trim()
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            Path    = $repo
            Name    = $name
            Status  = "Failed"
            Details = $_.Exception.Message
        }
    }
    finally {
        Pop-Location
    }
} -ThrottleLimit $Parallel

# 5. Display Statuses
foreach ($r in ($results | Sort-Object Name)) {
    switch ($r.Status) {
        "Updated" {
            Write-Host "  [+] $($r.Name): Updated" -ForegroundColor Green
        }
        "Up-to-date" {
            Write-Host "  [*] $($r.Name): Up-to-date" -ForegroundColor DarkGray
        }
        "Fetched" {
            Write-Host "  [*] $($r.Name): Fetched" -ForegroundColor Cyan
        }
        "Skipped (Dirty)" {
            Write-Host "  [!] $($r.Name): Skipped (Uncommitted changes present)" -ForegroundColor Yellow
        }
        "Skipped (No Upstream)" {
            Write-Host "  [!] $($r.Name): Skipped (No upstream tracking branch)" -ForegroundColor DarkYellow
        }
        "DryRun" {
            Write-Host "  [?] $($r.Name): Ready" -ForegroundColor Cyan
        }
        default {
            Write-Host "  [-] $($r.Name): Failed ($($r.Details))" -ForegroundColor Red
        }
    }
}

# 6. Summary Card
$updatedCount  = @($results | Where-Object Status -eq "Updated").Count
$upToDateCount = @($results | Where-Object Status -eq "Up-to-date").Count
$dirtyCount    = @($results | Where-Object Status -eq "Skipped (Dirty)").Count
$noUpstream    = @($results | Where-Object Status -eq "Skipped (No Upstream)").Count
$failedCount   = @($results | Where-Object Status -eq "Failed").Count
$total         = $results.Count

$borderColor = if ($failedCount -gt 0) { "196" } elseif ($updatedCount -gt 0) { "42" } else { "245" }
$summaryText = "Total: $total | Updated: $updatedCount | Up-to-date: $upToDateCount | Dirty: $dirtyCount | Failed: $failedCount"

Show-SummaryCard -Title "Git Repositories Sync Summary" -BorderColor $borderColor -Message $summaryText
