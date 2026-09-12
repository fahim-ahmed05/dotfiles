<#
.SYNOPSIS
    Stops/cancels a running or queued GitHub Actions workflow run.

.DESCRIPTION
    Cancels GitHub workflow runs interactively or via parameters.
    Automatically discovers repository and owner from the local git remote if available.
    Automatically retrieves the GitHub token via 'gh auth token' or environment variables.
    If no RunId is specified, lists active and recent workflow runs for interactive selection via gum or fzf.

.PARAMETER Owner
    The GitHub repository owner (user or organization). Defaults to origin remote if available.

.PARAMETER Repo
    The GitHub repository name. Defaults to origin remote if available.

.PARAMETER RunId
    The database ID of the workflow run to cancel. If omitted, presents an interactive list.

.PARAMETER Token
    GitHub personal access token or OAuth token. Automatically resolved if omitted.

.PARAMETER Force
    Uses GitHub force-cancel endpoint instead of standard cancel.

.EXAMPLE
    .\Stop-GitHubAction.ps1
    (Interactive selection from current repository runs)

.EXAMPLE
    .\Stop-GitHubAction.ps1 -RunId 123456789

.EXAMPLE
    .\Stop-GitHubAction.ps1 -Owner "octocat" -Repo "hello-world" -RunId 123456789 -Force
#>

param(
    [string]$Owner,
    [string]$Repo,
    [long]$RunId = 0,
    [string]$Token,
    [switch]$Force
)

function Clear-ConsoleInput {
    try {
        if ($Host.UI.RawUI.KeyAvailable) {
            while ($Host.UI.RawUI.KeyAvailable) { $null = [Console]::ReadKey($true) }
        }
        $Host.UI.RawUI.FlushInputBuffer()
    }
    catch {}
}

function Show-Card {
    param(
        [string]$Message,
        [string]$BorderColor = "212",
        [string]$Title = ""
    )
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        $content = if ($Title) { "$Title`n$Message" } else { $Message }
        gum style --border normal --border-foreground $BorderColor --padding "0 2" --margin "1 0" $content
    }
    else {
        if ($Title) { Write-Host "`n=== $Title ===" -ForegroundColor Cyan }
        Write-Host $Message
    }
}

function Get-GitRemoteRepo {
    try {
        $remoteUrl = git remote get-url origin 2>$null
        if ([string]::IsNullOrWhiteSpace($remoteUrl)) { return $null }

        # Matches: git@github.com:owner/repo.git or https://github.com/owner/repo.git
        if ($remoteUrl -match 'github\.com[:/](?<owner>[^/]+)/(?<repo>[^/\.]+)(?:\.git)?$') {
            return @{
                Owner = $Matches['owner']
                Repo  = $Matches['repo']
            }
        }
    }
    catch {}
    return $null
}

function Resolve-GitHubToken {
    if (-not [string]::IsNullOrWhiteSpace($Token)) { return $Token }
    if (-not [string]::IsNullOrWhiteSpace($env:GH_TOKEN)) { return $env:GH_TOKEN }
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) { return $env:GITHUB_TOKEN }

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $ghToken = (gh auth token 2>$null).Trim()
            if (-not [string]::IsNullOrWhiteSpace($ghToken)) {
                return $ghToken
            }
        }
        catch {}
    }
    return $null
}

# 1. Resolve Owner and Repo
if ([string]::IsNullOrWhiteSpace($Owner) -or [string]::IsNullOrWhiteSpace($Repo)) {
    $inferred = Get-GitRemoteRepo
    if ($inferred) {
        if ([string]::IsNullOrWhiteSpace($Owner)) { $Owner = $inferred.Owner }
        if ([string]::IsNullOrWhiteSpace($Repo)) { $Repo = $inferred.Repo }
    }
}

if ([string]::IsNullOrWhiteSpace($Owner)) {
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        $Owner = (gum input --prompt "Repository Owner: " --placeholder "e.g. octocat").Trim()
    }
    else {
        $Owner = (Read-Host "Enter Repository Owner").Trim()
    }
}

if ([string]::IsNullOrWhiteSpace($Repo)) {
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        $Repo = (gum input --prompt "Repository Name: " --placeholder "e.g. dotfiles").Trim()
    }
    else {
        $Repo = (Read-Host "Enter Repository Name").Trim()
    }
}

if ([string]::IsNullOrWhiteSpace($Owner) -or [string]::IsNullOrWhiteSpace($Repo)) {
    Write-Host "[-] Repository Owner and Repo name are required." -ForegroundColor Red
    exit 1
}

$Token = Resolve-GitHubToken

# 2. Resolve RunId if not provided
if ($RunId -le 0) {
    Write-Host "[*] Fetching active/recent workflow runs for $Owner/$Repo..." -ForegroundColor DarkGray
    $runs = @()

    # Try fetching with gh CLI first
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $json = gh run list --repo "$Owner/$Repo" --limit 25 --json databaseId,workflowName,displayTitle,headBranch,status,conclusion,createdAt 2>$null
            if ($json) {
                $runs = $json | ConvertFrom-Json
            }
        }
        catch {}
    }

    # Fallback to GitHub REST API if gh wasn't able to return runs
    if (-not $runs -or $runs.Count -eq 0) {
        $apiHeaders = @{
            "Accept"               = "application/vnd.github+json"
            "X-GitHub-Api-Version" = "2022-11-28"
        }
        if ($Token) {
            $apiHeaders["Authorization"] = "Bearer $Token"
        }

        try {
            $uri = "https://api.github.com/repos/$Owner/$Repo/actions/runs?per_page=25"
            $response = Invoke-RestMethod -Uri $uri -Headers $apiHeaders -Method Get -ErrorAction Stop
            if ($response.workflow_runs) {
                $runs = $response.workflow_runs | ForEach-Object {
                    [PSCustomObject]@{
                        databaseId   = $_.id
                        workflowName = $_.name
                        displayTitle = $_.display_title
                        headBranch   = $_.head_branch
                        status       = $_.status
                        conclusion   = $_.conclusion
                        createdAt    = $_.created_at
                    }
                }
            }
        }
        catch {
            Write-Host "[-] Could not retrieve workflow runs: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }

    if (-not $runs -or $runs.Count -eq 0) {
        Write-Host "[-] No workflow runs found for $Owner/$Repo." -ForegroundColor Yellow
        exit 0
    }

    # Prioritize active/queued runs first
    $activeRuns = @($runs | Where-Object { $_.status -in @("in_progress", "queued", "waiting", "requested") })
    $displayRuns = if ($activeRuns.Count -gt 0) { $activeRuns } else { $runs }

    $menuItems = @()
    foreach ($r in $displayRuns) {
        $statusStr = if ($r.status -in @("in_progress", "queued")) { $r.status.ToUpper() } else { "$($r.status) ($($r.conclusion))" }
        $title = if ($r.displayTitle) { $r.displayTitle } else { $r.workflowName }
        $item = "$($r.databaseId) | [$statusStr] $($r.workflowName): $title ($($r.headBranch))"
        $menuItems += $item
    }

    $selectedItem = $null
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        Write-Host "`nSelect workflow run to cancel:" -ForegroundColor Cyan
        $selectedItem = ($menuItems | gum choose)
        Clear-ConsoleInput
    }
    elseif (Get-Command fzf -ErrorAction SilentlyContinue) {
        $selectedItem = ($menuItems | fzf --prompt="Select run to cancel: ")
        Clear-ConsoleInput
    }
    else {
        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            Write-Host "[$i] $($menuItems[$i])"
        }
        $choice = Read-Host "Select run number (0-$($menuItems.Count - 1))"
        if ($choice -match '^\d+$' -and [int]$choice -lt $menuItems.Count) {
            $selectedItem = $menuItems[[int]$choice]
        }
    }

    if ([string]::IsNullOrWhiteSpace($selectedItem)) {
        Write-Host "[*] No run selected. Exiting." -ForegroundColor DarkGray
        exit 0
    }

    $RunId = [long]($selectedItem -split '\|')[0].Trim()
}

# 3. Perform Cancellation
Write-Host "[*] Cancelling workflow run $RunId on $Owner/$Repo..." -ForegroundColor Cyan

$endpoint = if ($Force) { "force-cancel" } else { "cancel" }

# If gh CLI is available and not forcing or authenticated via gh
$cancelled = $false
if (-not $Force -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    try {
        gh run cancel $RunId --repo "$Owner/$Repo" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $cancelled = $true
        }
    }
    catch {}
}

if (-not $cancelled) {
    if ([string]::IsNullOrWhiteSpace($Token)) {
        Write-Host "[-] GitHub Token is required to cancel via API. Authenticate with 'gh auth login' or provide -Token." -ForegroundColor Red
        exit 1
    }

    $uri = "https://api.github.com/repos/$Owner/$Repo/actions/runs/$RunId/$endpoint"
    $headers = @{
        "Accept"               = "application/vnd.github+json"
        "Authorization"        = "Bearer $Token"
        "X-GitHub-Api-Version" = "2022-11-28"
    }

    try {
        $null = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ErrorAction Stop
        $cancelled = $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 409) {
            Write-Host "[!] Run $RunId cannot be cancelled (it may already be completed)." -ForegroundColor Yellow
            exit 0
        }
        elseif ($statusCode -eq 404) {
            Write-Host "[-] Run $RunId not found in $Owner/$Repo." -ForegroundColor Red
            exit 1
        }
        else {
            Write-Host "[-] API request failed: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
}

if ($cancelled) {
    Show-Card -Title "GitHub Action Cancelled" -BorderColor "42" -Message "Repository: $Owner/$Repo`nRun ID:     $RunId`nAction:     $endpoint"
}
