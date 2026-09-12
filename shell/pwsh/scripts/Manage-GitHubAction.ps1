<#
.SYNOPSIS
    Interactive dashboard and manager for GitHub Actions workflows.

.DESCRIPTION
    Provides a real-time terminal dashboard and management interface for GitHub Actions.
    Displays running/queued workflows, execution elapsed times, recent run outcomes,
    and allows triggering, watching, inspecting, cancelling, rerunning, and downloading
    workflow artifacts. Uses fzf for all selections.

.PARAMETER Action
    Direct action to perform: 'dashboard', 'run', 'watch', 'view', 'cancel', 'rerun', 'download', 'list'.
    If omitted, displays the interactive dashboard and menu.

.PARAMETER Owner
    The GitHub repository owner. Inferred from git remote if omitted.

.PARAMETER Repo
    The GitHub repository name. Inferred from git remote if omitted.

.PARAMETER RunId
    The database ID of a specific workflow run.

.PARAMETER Workflow
    The name or file path of a workflow to trigger (e.g. 'build.yml').

.PARAMETER Ref
    Branch or tag for triggering a workflow. Defaults to the current git branch.

.PARAMETER FailedOnly
    When rerunning, only retries failed jobs instead of the entire workflow.

.PARAMETER Force
    When cancelling, uses GitHub force-cancel endpoint.

.EXAMPLE
    Manage-GitHubAction
    (Launches the interactive dashboard and menu)

.EXAMPLE
    Manage-GitHubAction -Action cancel

.EXAMPLE
    Manage-GitHubAction -Action run -Workflow build.yml -Ref main
#>

[CmdletBinding()]
param(
    [ValidateSet("dashboard", "run", "watch", "view", "cancel", "rerun", "download", "list", "")]
    [string]$Action = "dashboard",

    [string]$Owner,
    [string]$Repo,
    [long]$RunId = 0,
    [string]$Workflow,
    [string]$Ref,
    [string]$Token,
    [switch]$FailedOnly,
    [switch]$Force
)

# --- Encoding & Safety ---
$global:utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $global:utf8NoBom
[Console]::InputEncoding  = $global:utf8NoBom
$OutputEncoding           = $global:utf8NoBom

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

function Get-CurrentBranch {
    try {
        $branch = (git branch --show-current 2>$null).Trim()
        if ($branch) { return $branch }
    }
    catch {}
    return "main"
}

function Resolve-GitHubToken {
    if (-not [string]::IsNullOrWhiteSpace($Token)) { return $Token }
    if (-not [string]::IsNullOrWhiteSpace($env:GH_TOKEN)) { return $env:GH_TOKEN }
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) { return $env:GITHUB_TOKEN }

    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $ghToken = (gh auth token 2>$null).Trim()
            if (-not [string]::IsNullOrWhiteSpace($ghToken)) { return $ghToken }
        }
        catch {}
    }
    return $null
}

function Format-Duration ([TimeSpan]$ts) {
    if ($ts.TotalHours -ge 1) {
        return "{0}h {1}m" -f [int]$ts.TotalHours, $ts.Minutes
    }
    elseif ($ts.TotalMinutes -ge 1) {
        return "{0}m {1}s" -f [int]$ts.TotalMinutes, $ts.Seconds
    }
    else {
        $sec = [int]$ts.TotalSeconds
        if ($sec -lt 1) { $sec = 1 }
        return "{0}s" -f $sec
    }
}

function Format-TimeAgo ([DateTime]$utcTime) {
    $diff = [DateTime]::UtcNow - $utcTime
    if ($diff.TotalDays -ge 1) {
        return "{0}d ago" -f [int]$diff.TotalDays
    }
    elseif ($diff.TotalHours -ge 1) {
        return "{0}h ago" -f [int]$diff.TotalHours
    }
    elseif ($diff.TotalMinutes -ge 1) {
        return "{0}m ago" -f [int]$diff.TotalMinutes
    }
    else {
        return "just now"
    }
}

# 1. Resolve Repository Context
if ([string]::IsNullOrWhiteSpace($Owner) -or [string]::IsNullOrWhiteSpace($Repo)) {
    $inferred = Get-GitRemoteRepo
    if ($inferred) {
        if ([string]::IsNullOrWhiteSpace($Owner)) { $Owner = $inferred.Owner }
        if ([string]::IsNullOrWhiteSpace($Repo))  { $Repo  = $inferred.Repo }
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
    Write-Host "[-] Repository Owner and Name are required." -ForegroundColor Red
    exit 1
}

$repoTarget = "$Owner/$Repo"
$Token = Resolve-GitHubToken

# Helper to fetch runs as objects
function Get-WorkflowRuns ([int]$Limit = 25) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $json = gh run list --repo $repoTarget --limit $Limit --json databaseId,workflowName,displayTitle,event,headBranch,status,conclusion,startedAt,createdAt,updatedAt 2>$null
            if ($json) {
                return @($json | ConvertFrom-Json)
            }
        }
        catch {}
    }

    # REST API Fallback
    $apiHeaders = @{
        "Accept"               = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    if ($Token) { $apiHeaders["Authorization"] = "Bearer $Token" }

    try {
        $uri = "https://api.github.com/repos/$repoTarget/actions/runs?per_page=$Limit"
        $response = Invoke-RestMethod -Uri $uri -Headers $apiHeaders -Method Get -ErrorAction Stop
        if ($response.workflow_runs) {
            return @($response.workflow_runs | ForEach-Object {
                [PSCustomObject]@{
                    databaseId   = $_.id
                    workflowName = $_.name
                    displayTitle = $_.display_title
                    event        = $_.event
                    headBranch   = $_.head_branch
                    status       = $_.status
                    conclusion   = $_.conclusion
                    startedAt    = $_.run_started_at
                    createdAt    = $_.created_at
                    updatedAt    = $_.updated_at
                }
            })
        }
    }
    catch {}

    return @()
}

# 2. Render Dashboard Card
function Show-DashboardView {
    $runs = Get-WorkflowRuns -Limit 20
    $currBranch = Get-CurrentBranch
    $now = [DateTime]::UtcNow

    $active = @($runs | Where-Object { $_.status -in @("in_progress", "queued", "waiting", "requested") })
    $completed = @($runs | Where-Object { $_.status -eq "completed" })

    $dashLines = [System.Collections.Generic.List[string]]::new()
    $dashLines.Add("Repository: $repoTarget  (Branch: $currBranch)")
    $dashLines.Add("")

    # Active Runs Section
    if ($active.Count -gt 0) {
        $dashLines.Add("ACTIVE WORKFLOW RUNS ($($active.Count)):")
        foreach ($r in $active) {
            $elapsedStr = ""
            if ($r.startedAt) {
                try {
                    $st = [DateTime]::Parse($r.startedAt).ToUniversalTime()
                    $elapsedStr = " - running for " + (Format-Duration ($now - $st))
                }
                catch {}
            }
            $dashLines.Add("  [*] #$($r.databaseId) [$($r.status.ToUpper())] $($r.workflowName)")
            $dashLines.Add("      Title:  $($r.displayTitle)")
            $dashLines.Add("      Branch: $($r.headBranch) | Event: $($r.event)$elapsedStr")
        }
    }
    else {
        $dashLines.Add("ACTIVE RUNS: None (All idle)")
    }

    $dashLines.Add("")

    # Recent Runs Section
    $dashLines.Add("RECENT RUNS:")
    if ($completed.Count -gt 0) {
        $topCompleted = $completed | Select-Object -First 5
        foreach ($r in $topCompleted) {
            $conclStr = if ($r.conclusion) { $r.conclusion.ToUpper() } else { "UNKNOWN" }
            $tag = switch ($r.conclusion) {
                "success"   { "[+]" }
                "failure"   { "[-]" }
                "cancelled" { "[o]" }
                default     { "[?]" }
            }

            $durStr = ""
            if ($r.startedAt -and $r.updatedAt) {
                try {
                    $st = [DateTime]::Parse($r.startedAt).ToUniversalTime()
                    $up = [DateTime]::Parse($r.updatedAt).ToUniversalTime()
                    $durStr = " - " + (Format-Duration ($up - $st))
                }
                catch {}
            }

            $agoStr = ""
            if ($r.updatedAt) {
                try {
                    $up = [DateTime]::Parse($r.updatedAt).ToUniversalTime()
                    $agoStr = " (" + (Format-TimeAgo $up) + ")"
                }
                catch {}
            }

            $titleShort = if ($r.displayTitle.Length -gt 35) { $r.displayTitle.Substring(0, 32) + "..." } else { $r.displayTitle }
            $dashLines.Add("  $tag #$($r.databaseId) [$conclStr] $($r.workflowName): $titleShort ($($r.headBranch))$durStr$agoStr")
        }
    }
    else {
        $dashLines.Add("  No recent completed runs.")
    }

    $dashLines.Add("")

    # Summary Counts
    $successCount = @($completed | Where-Object conclusion -eq "success").Count
    $failCount    = @($completed | Where-Object conclusion -eq "failure").Count
    $cancelCount  = @($completed | Where-Object conclusion -eq "cancelled").Count
    $dashLines.Add("Quick Stats: $($runs.Count) Total | $($active.Count) Active | $successCount Success | $failCount Failed | $cancelCount Cancelled")

    $borderColor = if ($active.Count -gt 0) { "39" } elseif ($failCount -gt 0) { "214" } else { "42" }
    Show-Card -Title "GitHub Actions Dashboard" -BorderColor $borderColor -Message ($dashLines -join "`n")
}

# --- Action Implementations ---

function Invoke-RunWorkflow {
    Write-Host "[*] Fetching available workflows for $repoTarget..." -ForegroundColor DarkGray
    $workflows = @()
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            $json = gh workflow list --repo $repoTarget --json id,name,path,state 2>$null
            if ($json) { $workflows = @($json | ConvertFrom-Json) }
        }
        catch {}
    }

    if ($workflows.Count -eq 0) {
        Write-Host "[-] No workflows found in $repoTarget." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($w in $workflows) {
        $stateTag = if ($w.state -eq "active") { "[ACTIVE]" } else { "[$($w.state.ToUpper())]" }
        $items += "$($w.path) | $stateTag $($w.name)"
    }

    $selected = $null
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        $selected = ($items | fzf --prompt="Select workflow to run: " --height=~40% --reverse --header="ENTER: Run | ESC: Cancel")
        Clear-ConsoleInput
    }
    else {
        $selected = $items[0]
    }

    if (-not $selected) {
        Write-Host "[*] Operation cancelled." -ForegroundColor DarkGray
        return
    }

    $wfPath = ($selected -split '\|')[0].Trim()
    $defaultBranch = Get-CurrentBranch

    $targetRef = $Ref
    if ([string]::IsNullOrWhiteSpace($targetRef)) {
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            $targetRef = (gum input --prompt "Target Branch / Ref: " --value $defaultBranch).Trim()
            Clear-ConsoleInput
        }
        else {
            $targetRef = Read-Host "Target Branch / Ref [$defaultBranch]"
            if ([string]::IsNullOrWhiteSpace($targetRef)) { $targetRef = $defaultBranch }
        }
    }

    Write-Host "[*] Triggering workflow $wfPath on branch $targetRef..." -ForegroundColor Cyan
    gh workflow run $wfPath --repo $repoTarget --ref $targetRef

    if ($LASTEXITCODE -eq 0) {
        Show-Card -Title "Workflow Dispatched" -BorderColor "42" -Message "Workflow: $wfPath`nBranch:   $targetRef`nStatus:   Queued on GitHub"

        $watchChoice = "No"
        if (Get-Command fzf -ErrorAction SilentlyContinue) {
            $watchChoice = @("Yes", "No") | fzf --prompt="Watch execution live? " --height=~20% --reverse
            Clear-ConsoleInput
        }
        elseif (Get-Command gum -ErrorAction SilentlyContinue) {
            Write-Host "`nWould you like to watch execution live?" -ForegroundColor Cyan
            $watchChoice = gum choose "Yes" "No"
            Clear-ConsoleInput
        }
        if ($watchChoice -eq "Yes") {
            Start-Sleep -Seconds 3
            gh run watch --repo $repoTarget
        }
    }
    else {
        Write-Host "[-] Failed to trigger workflow. Ensure 'workflow_dispatch' is declared in the workflow YAML." -ForegroundColor Red
    }
}

function Invoke-WatchRun {
    $runs = Get-WorkflowRuns -Limit 25
    $active = @($runs | Where-Object { $_.status -in @("in_progress", "queued", "waiting", "requested") })
    $candidateRuns = if ($active.Count -gt 0) { $active } else { $runs }

    if ($candidateRuns.Count -eq 0) {
        Write-Host "[-] No active or recent runs to watch in $repoTarget." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($r in $candidateRuns) {
        $statusStr = if ($r.status -in @("in_progress", "queued")) { $r.status.ToUpper() } else { "$($r.status) ($($r.conclusion))" }
        $items += "$($r.databaseId) | [$statusStr] $($r.workflowName): $($r.displayTitle) ($($r.headBranch))"
    }

    $selected = ($items | fzf --prompt="Select run to watch live: " --height=~40% --reverse --header="ENTER: Watch | ESC: Cancel")
    Clear-ConsoleInput
    if (-not $selected) { return }

    $targetRunId = [long]($selected -split '\|')[0].Trim()
    Write-Host "[*] Watching run $targetRunId in real-time (Press Ctrl+C to stop watching)..." -ForegroundColor Cyan
    gh run watch $targetRunId --repo $repoTarget
}

function Invoke-ViewRunLogs {
    $runs = Get-WorkflowRuns -Limit 25
    if ($runs.Count -eq 0) {
        Write-Host "[-] No workflow runs found in $repoTarget." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($r in $runs) {
        $concl = if ($r.conclusion) { $r.conclusion.ToUpper() } else { $r.status.ToUpper() }
        $items += "$($r.databaseId) | [$concl] $($r.workflowName): $($r.displayTitle) ($($r.headBranch))"
    }

    $selected = ($items | fzf --prompt="Select run to view: " --height=~40% --reverse --header="ENTER: Select | ESC: Cancel")
    Clear-ConsoleInput
    if (-not $selected) { return }

    $targetRunId = [long]($selected -split '\|')[0].Trim()

    $logOptions = @(
        "Summary & Jobs (overview)"
        "Failed Steps Only (--log-failed)"
        "Full Execution Log (--log)"
    )
    $logMode = "Summary & Jobs"
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        $logMode = ($logOptions | fzf --prompt="Select Log View Mode: " --height=~25% --reverse)
        Clear-ConsoleInput
    }
    elseif (Get-Command gum -ErrorAction SilentlyContinue) {
        Write-Host "`nSelect Log View Mode:" -ForegroundColor Cyan
        $logMode = gum choose $logOptions
        Clear-ConsoleInput
    }

    switch -Wildcard ($logMode) {
        "*Failed Steps*" {
            gh run view $targetRunId --repo $repoTarget --log-failed
        }
        "*Full Execution*" {
            gh run view $targetRunId --repo $repoTarget --log
        }
        default {
            gh run view $targetRunId --repo $repoTarget
        }
    }
}

function Invoke-CancelRun {
    $runs = Get-WorkflowRuns -Limit 25
    $activeRuns = @($runs | Where-Object { $_.status -in @("in_progress", "queued", "waiting", "requested") })
    $displayRuns = if ($activeRuns.Count -gt 0) { $activeRuns } else { $runs }

    if ($displayRuns.Count -eq 0) {
        Write-Host "[-] No active or recent runs to cancel." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($r in $displayRuns) {
        $statusStr = if ($r.status -in @("in_progress", "queued")) { $r.status.ToUpper() } else { "$($r.status) ($($r.conclusion))" }
        $items += "$($r.databaseId) | [$statusStr] $($r.workflowName): $($r.displayTitle) ($($r.headBranch))"
    }

    $selected = ($items | fzf --prompt="Select workflow run to cancel: " --height=~40% --reverse --header="ENTER: Cancel Run | ESC: Exit")
    Clear-ConsoleInput
    if (-not $selected) { return }

    $targetRunId = [long]($selected -split '\|')[0].Trim()

    Write-Host "[*] Cancelling run $targetRunId in $repoTarget..." -ForegroundColor Cyan
    $endpoint = if ($Force) { "force-cancel" } else { "cancel" }

    $cancelled = $false
    if (-not $Force -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        try {
            gh run cancel $targetRunId --repo $repoTarget 2>$null
            if ($LASTEXITCODE -eq 0) { $cancelled = $true }
        }
        catch {}
    }

    if (-not $cancelled -and $Token) {
        $uri = "https://api.github.com/repos/$repoTarget/actions/runs/$targetRunId/$endpoint"
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
            Write-Host "[-] Cancellation failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    if ($cancelled) {
        Show-Card -Title "Run Cancelled" -BorderColor "42" -Message "Run ID:     $targetRunId`nRepository: $repoTarget`nAction:     $endpoint"
    }
}

function Invoke-RerunWorkflow {
    $runs = Get-WorkflowRuns -Limit 25
    $completed = @($runs | Where-Object { $_.status -eq "completed" })

    if ($completed.Count -eq 0) {
        Write-Host "[-] No completed runs available to rerun." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($r in $completed) {
        $concl = if ($r.conclusion) { $r.conclusion.ToUpper() } else { "UNKNOWN" }
        $items += "$($r.databaseId) | [$concl] $($r.workflowName): $($r.displayTitle) ($($r.headBranch))"
    }

    $selected = ($items | fzf --prompt="Select workflow run to rerun: " --height=~40% --reverse --header="ENTER: Select | ESC: Cancel")
    Clear-ConsoleInput
    if (-not $selected) { return }

    $targetRunId = [long]($selected -split '\|')[0].Trim()

    $rerunOptions = @(
        "Failed jobs only (--failed)"
        "Entire workflow (all jobs)"
    )
    $rerunChoice = "Failed jobs only"
    if (-not $FailedOnly) {
        if (Get-Command fzf -ErrorAction SilentlyContinue) {
            $rerunChoice = ($rerunOptions | fzf --prompt="Select Rerun Mode: " --height=~20% --reverse)
            Clear-ConsoleInput
        }
        elseif (Get-Command gum -ErrorAction SilentlyContinue) {
            Write-Host "`nRerun Mode:" -ForegroundColor Cyan
            $rerunChoice = gum choose $rerunOptions
            Clear-ConsoleInput
        }
    }

    if ($FailedOnly -or $rerunChoice -like "*Failed jobs*") {
        Write-Host "[*] Retrying failed jobs in run $targetRunId..." -ForegroundColor Cyan
        gh run rerun $targetRunId --repo $repoTarget --failed
    }
    else {
        Write-Host "[*] Retrying entire workflow for run $targetRunId..." -ForegroundColor Cyan
        gh run rerun $targetRunId --repo $repoTarget
    }

    if ($LASTEXITCODE -eq 0) {
        Show-Card -Title "Workflow Rerun Initiated" -BorderColor "42" -Message "Run ID:     $targetRunId`nRepository: $repoTarget"
    }
}

function Invoke-DownloadArtifacts {
    $runs = Get-WorkflowRuns -Limit 25
    if ($runs.Count -eq 0) {
        Write-Host "[-] No runs available in $repoTarget." -ForegroundColor Yellow
        return
    }

    $items = @()
    foreach ($r in $runs) {
        $concl = if ($r.conclusion) { $r.conclusion.ToUpper() } else { $r.status.ToUpper() }
        $items += "$($r.databaseId) | [$concl] $($r.workflowName): $($r.displayTitle) ($($r.headBranch))"
    }

    $selected = ($items | fzf --prompt="Select run to download artifacts from: " --height=~40% --reverse --header="ENTER: Download | ESC: Cancel")
    Clear-ConsoleInput
    if (-not $selected) { return }

    $targetRunId = [long]($selected -split '\|')[0].Trim()
    Write-Host "[*] Downloading artifacts for run $targetRunId..." -ForegroundColor Cyan
    gh run download $targetRunId --repo $repoTarget
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[+] Artifacts downloaded to current directory." -ForegroundColor Green
    }
}

# --- Main Entry Point ---

switch ($Action) {
    "run"      { Invoke-RunWorkflow; exit }
    "watch"    { Invoke-WatchRun; exit }
    "view"     { Invoke-ViewRunLogs; exit }
    "cancel"   { Invoke-CancelRun; exit }
    "rerun"    { Invoke-RerunWorkflow; exit }
    "download" { Invoke-DownloadArtifacts; exit }
    "list"     { Show-DashboardView; exit }
    default    {
        # Interactive Dashboard & Menu Loop
        while ($true) {
            Clear-Host
            Show-DashboardView

            $choices = @(
                "1. Start / Run Workflow (gh workflow run)"
                "2. Watch Live Run (gh run watch)"
                "3. View Run Logs & Errors (gh run view)"
                "4. Cancel / Stop Run (gh run cancel)"
                "5. Rerun Workflow (gh run rerun)"
                "6. Download Run Artifacts (gh run download)"
                "7. Refresh Dashboard"
                "8. Exit"
            )

            $chosen = $null
            if (Get-Command fzf -ErrorAction SilentlyContinue) {
                $chosen = ($choices | fzf --prompt="Select Action: " --height=~35% --reverse --header="GitHub Actions Menu (ESC to exit)")
                Clear-ConsoleInput
            }
            elseif (Get-Command gum -ErrorAction SilentlyContinue) {
                Write-Host "Select Action:" -ForegroundColor Cyan
                $chosen = gum choose $choices
                Clear-ConsoleInput
            }

                if (-not $chosen -or $chosen -like "*Exit*") { break }

                switch -Wildcard ($chosen) {
                    "1.*" { Invoke-RunWorkflow }
                    "2.*" { Invoke-WatchRun }
                    "3.*" { Invoke-ViewRunLogs }
                    "4.*" { Invoke-CancelRun }
                    "5.*" { Invoke-RerunWorkflow }
                    "6.*" { Invoke-DownloadArtifacts }
                    "7.*" { continue }
                }

                Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
                $null = [Console]::ReadKey($true)
            }
            else {
                Write-Host "`nActions: [1] Run [2] Watch [3] View Logs [4] Cancel [5] Rerun [6] Download [7] Refresh [8] Exit"
                $choice = Read-Host "Select action"
                switch ($choice) {
                    "1" { Invoke-RunWorkflow }
                    "2" { Invoke-WatchRun }
                    "3" { Invoke-ViewRunLogs }
                    "4" { Invoke-CancelRun }
                    "5" { Invoke-RerunWorkflow }
                    "6" { Invoke-DownloadArtifacts }
                    "7" { continue }
                    default { break }
                }
            }
        }
    }
}
