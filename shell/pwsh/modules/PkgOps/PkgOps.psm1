<#
.SYNOPSIS
    Interactive unified package manager module for Winget and Scoop.
.DESCRIPTION
    PkgOps combines Scoop and Winget into a unified, interactive terminal package manager.
    It provides instant catalog searching across 20,000+ packages via fzf,
    rich terminal styling via Charm Gum, exact bucket and source preservation,
    and on-demand package inspection via Shift+?.
#>

function Get-CombinedCatalog {
    <#
    .SYNOPSIS
        Rapidly extracts and formats all available packages from Scoop and Winget in memory.
    #>
    $dbItem = Get-Item "$env:ProgramFiles\WindowsApps\Microsoft.Winget.Source_*\Public\index.db" -ErrorAction SilentlyContinue | Select-Object -Last 1
    $dbPath = if ($dbItem) { $dbItem.FullName } else { "" }
    $scoopPath = "$env:UserProfile\Git\fast-scoop-search\scoop-index.json"

    # Use Python to rapidly parse both Scoop JSON and Winget SQLite in memory (~130ms)
    $lines = python -c "
import sys, sqlite3, json

esc = '\x1b'
w_color = f'{esc}[38;5;39m'
s_color = f'{esc}[38;5;214m'
dim = f'{esc}[38;5;245m'
reset = f'{esc}[0m'

def trunc(s, max_len):
    return s[:max_len-1] + '…' if len(s) > max_len else s

lines = []

# 1. Scoop packages from scoop-index.json
if r'$scoopPath':
    try:
        with open(r'$scoopPath', 'r', encoding='utf-8') as f:
            sdata = json.load(f)
        for bucket, bval in sdata.items():
            if isinstance(bval, dict) and 'packages' in bval:
                for pkg, ver in bval['packages'].items():
                    b_text = f'scoop:{bucket}'
                    badge = f'{s_color}[{b_text}]{reset}'
                    pad = ' ' * max(2, 20 - len(b_text) - 2)
                    disp_pkg = trunc(pkg, 40)
                    disp_ver = trunc(ver, 16)
                    raw = f'scoop:{bucket}/{pkg}'
                    disp = f'{badge}{pad}{disp_pkg:<40}  {disp_ver:<16}'
                    lines.append(f'{raw}\t{disp}')
    except Exception:
        pass

# 2. Winget packages from native index.db
if r'$dbPath':
    try:
        conn = sqlite3.connect(r'$dbPath')
        c = conn.cursor()
        c.execute('SELECT id, name, latest_version FROM packages;')
        for id, name, ver in c:
            v = ver or ''
            n = name or ''
            badge = f'{w_color}[winget:winget]{reset}'
            pad = ' ' * 5
            disp_id = trunc(id, 40)
            disp_ver = trunc(v, 16)
            desc_str = f'  {dim}{n}{reset}' if n else ''
            raw = f'winget:{id}'
            disp = f'{badge}{pad}{disp_id:<40}  {disp_ver:<16}{desc_str}'
            lines.append(f'{raw}\t{disp}')
        conn.close()
    except Exception:
        pass

import sys
sys.stdout.write('\n'.join(lines) + '\n')
"
    return $lines
}

function Update-PackageSources {
    <#
    .SYNOPSIS
        Synchronizes upstream package manifests for Winget and Scoop.
    #>
    gum style --border rounded --border-foreground 39 --padding "0 2" --bold "Updating Winget Sources..."
    winget source update

    gum style --border rounded --border-foreground 214 --padding "0 2" --bold "Updating Scoop & Index..."
    scoop update
    
    $scoopSearchPath = "$env:UserProfile\Git\fast-scoop-search\Scoop-Search.ps1"
    if (Test-Path $scoopSearchPath) {
        # Trigger incremental index update in fast-scoop-search
        & $scoopSearchPath "__force_reindex_check__" 2>$null | Out-Null
    }

    gum style --border rounded --border-foreground 42 --padding "0 2" --bold "Package sources updated successfully!"
}

function Install-Packages {
    <#
    .SYNOPSIS
        Searches, browses, and installs packages from Scoop and Winget.
    .DESCRIPTION
        Loads available packages from Scoop's local index and Winget's native
        SQLite database in memory (~130ms) into an interactive fzf TUI.
        Supports multi-selection (<Tab>), query pre-filtering, exact bucket/source
        installation, and package info preview on Shift+?.
    .PARAMETER Packages
        Optional search term or explicit targets (e.g. 'neovim', 'scoop:extras/tor-browser').
        If omitted, opens fzf displaying the entire 20,000+ package catalog.
    .PARAMETER Update
        If specified, updates Winget sources and Scoop buckets before launching fzf.
    .EXAMPLE
        Install-Packages
        Opens fzf displaying all 20,000+ packages.
    .EXAMPLE
        Install-Packages neovim
        Opens fzf pre-filtered with the query 'neovim'.
    .EXAMPLE
        Install-Packages tor -Update
        Updates package sources first, then opens fzf pre-filtered to 'tor'.
    .EXAMPLE
        Install-Packages scoop:extras/tor-browser winget:Neovim.Neovim
        Directly installs specified packages bypassing fzf.
    #>
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [string[]]$Packages,
        [switch]$Update
    )

    if ($Update) {
        Update-PackageSources
    }

    # If all arguments have explicit manager prefix (e.g. scoop:main/git or winget:id), install directly
    $explicitMatches = if ($Packages) {
        @($Packages | Where-Object { $_ -match '^(winget|scoop|msstore):' })
    } else { @() }

    if ($Packages -and $Packages.Count -gt 0 -and $explicitMatches.Count -eq $Packages.Count) {
        foreach ($target in $Packages) {
            Invoke-SingleInstall -Target $target
        }
        if (Get-Command Remove-DesktopIcons -ErrorAction SilentlyContinue) {
            Remove-DesktopIcons
        }
        return
    }

    # Load complete package catalog (~20,200 packages)
    $catalog = Get-CombinedCatalog

    if (-not $catalog -or $catalog.Count -eq 0) {
        gum style --foreground 214 "[-] Unable to load package catalog. Check Winget and Scoop configuration."
        return
    }

    $previewScript = Join-Path $PSScriptRoot "Get-PackageInfo.py"
    $fzfHeader = "Tab: Multi-select │ Enter: Install │ ?: Info │ Esc: Cancel"
    $fzfArgs = @(
        '-m',
        '--ansi',
        '--no-hscroll',
        '--delimiter=\t',
        '--with-nth=2',
        '--nth=1,2',
        "--header=$fzfHeader",
        '--prompt=Search > ',
        '--pointer=▶',
        '--marker=✓',
        '--layout=reverse',
        '--border=rounded',
        '--preview-window=right:50%:hidden:wrap-word,<100(down:50%:hidden:wrap-word)',
        '--preview-wrap-sign=',
        "--preview=python `"$previewScript`" {1}",
        '--bind=?:toggle-preview'
    )

    if ($Packages -and $Packages.Count -gt 0) {
        $fzfArgs += "--query=$($Packages -join ' ')"
    }

    $selectedLines = $catalog | fzf @fzfArgs

    if (-not $selectedLines -or $selectedLines.Count -eq 0) {
        gum style --foreground 245 "[-] Installation cancelled. No packages selected."
        return
    }

    # Parse user selection
    $selectedTargets = [System.Collections.Generic.List[PSCustomObject]]::new()
    $summaryList = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $selectedLines) {
        $parts = $line.Split("`t")
        $raw = $parts[0].Trim()

        if ($raw -match '^scoop:(?<bucket>[^/]+)/(?<pkg>.+)$') {
            $bucket = $Matches['bucket']
            $pkg    = $Matches['pkg']
            $selectedTargets.Add([PSCustomObject]@{ Manager = 'scoop'; Target = "$bucket/$pkg"; Display = "[scoop:$bucket] $pkg" })
            $summaryList.Add("  • [scoop:$bucket] $pkg")
        } elseif ($raw -match '^winget:(?<id>.+)$') {
            $id = $Matches['id']
            $selectedTargets.Add([PSCustomObject]@{ Manager = 'winget'; Target = $id; Source = 'winget'; Display = "[winget:winget] $id" })
            $summaryList.Add("  • [winget:winget] $id")
        } else {
            $selectedTargets.Add([PSCustomObject]@{ Manager = 'unknown'; Target = $raw; Display = $raw })
            $summaryList.Add("  • $raw")
        }
    }

    if ($selectedTargets.Count -eq 0) { return }

    # Confirm installation
    $summaryText = $summaryList -join "`n"
    gum style --border rounded --border-foreground 212 --padding "0 2" --margin "1 0" `
        "Packages To Install ($($selectedTargets.Count)):`n$summaryText"

    gum confirm "Proceed with installation?"
    if ($LASTEXITCODE -ne 0) {
        gum style --foreground 245 "[-] Installation aborted."
        return
    }

    foreach ($item in $selectedTargets) {
        Invoke-SingleInstall -Target "$($item.Manager):$($item.Target)"
    }

    if (Get-Command Remove-DesktopIcons -ErrorAction SilentlyContinue) {
        Remove-DesktopIcons
    }
}

function Invoke-SingleInstall {
    <#
    .SYNOPSIS
        Executes the install command for a specific package manager target.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    $manager = $null
    $targetId = $Target

    if ($Target -match '^(?<mgr>winget|scoop|msstore):(?<id>.+)$') {
        $manager = $Matches['mgr']
        $targetId = $Matches['id']
    }
    elseif ($Target -match '^(?=.*\d)[A-Za-z0-9]{12}$') {
        $manager = 'msstore'
    }
    elseif ($Target -match '^[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$') {
        $manager = 'winget'
    }
    else {
        $manager = 'scoop'
    }

    switch ($manager) {
        'msstore' {
            gum style --border rounded --border-foreground 141 --padding "0 2" --bold "Installing $targetId via Microsoft Store..."
            winget install -e --id "$targetId" --source msstore --accept-package-agreements --accept-source-agreements
        }
        'winget' {
            gum style --border rounded --border-foreground 39 --padding "0 2" --bold "Installing $targetId via Winget..."
            winget install -e --id "$targetId" --source winget --accept-package-agreements --accept-source-agreements
        }
        'scoop' {
            gum style --border rounded --border-foreground 214 --padding "0 2" --bold "Installing $targetId via Scoop..."
            scoop install "$targetId"
        }
    }
}


function Invoke-PackageUninstall {
    <#
    .SYNOPSIS
        Executes uninstallation for a specific package manager target.
    #>
    param(
        [string]$Manager,
        [string]$Id
    )

    switch ($Manager) {
        { $_ -in 'msstore', 'winget' } {
            gum style --border rounded --border-foreground 39 --padding "0 2" --bold "Uninstalling $Id via Winget..."
            if ($Id -like 'MSIX\*') {
                winget uninstall --id "$Id"
            } else {
                winget uninstall -e --id "$Id"
            }
        }
        'scoop' {
            gum style --border rounded --border-foreground 214 --padding "0 2" --bold "Uninstalling $Id via Scoop..."
            scoop uninstall "$Id"
        }
    }
}

function Uninstall-Packages {
    <#
    .SYNOPSIS
        Searches and uninstalls applications installed via Scoop or Winget.
    .DESCRIPTION
        Queries installed apps across Scoop and Winget in parallel.
        If multiple apps match a query or if no query is provided, opens fzf
        with multi-select and Shift+? preview support. If exactly one app matches,
        prompts for immediate confirmation.
    .PARAMETER Packages
        Optional query or target app name (e.g. 'tor', 'scoop:tor-browser').
        If omitted, opens fzf displaying all currently installed programs.
    .PARAMETER Force
        Bypasses interactive confirmation prompts.
    .EXAMPLE
        Uninstall-Packages
        Opens fzf displaying all installed programs.
    .EXAMPLE
        Uninstall-Packages tor
        Filters installed programs matching 'tor' in fzf, or confirms if single match.
    .EXAMPLE
        Uninstall-Packages scoop:tor-browser -Force
        Directly uninstalls the specified Scoop app without confirmation.
    #>
    param(
        [Parameter(Position = 0, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [string[]]$Packages,
        [switch]$Force
    )

    # Check for direct explicit target (e.g. scoop:tor-browser or winget:id)
    if ($Packages -and $Packages.Count -eq 1 -and $Packages[0] -match '^(?<mgr>winget|scoop|msstore):(?<id>.+)$') {
        $mgr = $Matches['mgr']
        $id  = $Matches['id']

        if (-not $Force) {
            gum confirm "Are you sure you want to uninstall '$id' via $mgr?"
            if ($LASTEXITCODE -ne 0) {
                gum style --foreground 245 "[-] Skipped $id."
                return
            }
        }
        Invoke-PackageUninstall -Manager $mgr -Id $id
        return
    }

    # Fetch installed packages across Winget and Scoop in parallel
    $query = if ($Packages) { $Packages -join ' ' } else { "" }

    if ($query) {
        gum style --foreground 245 "Checking installed packages matching '$query'..."
    } else {
        gum style --foreground 245 "Fetching installed packages..."
    }

    $rawItems = @('winget', 'scoop') | ForEach-Object -Parallel {
        $q = $using:query
        if ($_ -eq 'winget') {
            $raw = if ($q) {
                winget list "$q" --accept-source-agreements 2>$null
            } else {
                winget list --accept-source-agreements 2>$null
            }
            [PSCustomObject]@{ Source = 'winget'; Raw = $raw }
        } else {
            $raw = if ($q) {
                scoop list "$q" | Out-String -Stream
            } else {
                scoop list | Out-String -Stream
            }
            [PSCustomObject]@{ Source = 'scoop'; Raw = $raw }
        }
    } -ThrottleLimit 2

    $installed = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($item in $rawItems) {
        if ($item.Source -eq 'winget') {
            $raw = $item.Raw
            $headerIdx = -1
            for ($i = 0; $i -lt $raw.Count; $i++) {
                if ($raw[$i] -match '^Name\s+Id\s+') {
                    $headerIdx = $i
                    break
                }
            }
            if ($headerIdx -ge 0) {
                $header   = $raw[$headerIdx]
                $idPos    = $header.IndexOf('Id')
                $verPos   = $header.IndexOf('Version')
                $srcPos   = $header.IndexOf('Source')

                for ($i = $headerIdx + 2; $i -lt $raw.Count; $i++) {
                    $line = $raw[$i]
                    if ([string]::IsNullOrWhiteSpace($line)) { continue }
                    $name = $line.Substring(0, [Math]::Min($line.Length, $idPos)).Trim()
                    $id = if ($line.Length -gt $idPos) {
                        $end = if ($verPos -gt $idPos) { [Math]::Min($line.Length, $verPos) } else { $line.Length }
                        $line.Substring($idPos, $end - $idPos).Trim()
                    } else { "" }
                    if (-not $id) { continue }
                    $ver = if ($verPos -gt 0 -and $line.Length -gt $verPos) {
                        $end = if ($srcPos -gt $verPos) { [Math]::Min($line.Length, $srcPos) } else { $line.Length }
                        $line.Substring($verPos, $end - $verPos).Trim()
                    } else { "" }
                    $src = if ($srcPos -gt 0 -and $line.Length -gt $srcPos) { $line.Substring($srcPos).Trim() } else { "" }
                    $mgr = if ($src -match 'msstore') { 'msstore' } else { 'winget' }

                    if (-not $query -or $name.Contains($query, [System.StringComparison]::OrdinalIgnoreCase) -or $id.Contains($query, [System.StringComparison]::OrdinalIgnoreCase)) {
                        $installed.Add([PSCustomObject]@{
                            Manager = $mgr
                            Source  = $src
                            Id      = $id
                            Name    = $name
                            Version = $ver
                        })
                    }
                }
            }
        }
        elseif ($item.Source -eq 'scoop') {
            $raw = $item.Raw
            $headerIdx = -1
            for ($i = 0; $i -lt $raw.Count; $i++) {
                if ($raw[$i] -match '^(Name|name)\s+(Version|version)\s+(Source|source)') {
                    $headerIdx = $i
                    break
                }
            }
            if ($headerIdx -ge 0) {
                $header = $raw[$headerIdx]
                $verPos = [regex]::Match($header, 'Version', 'IgnoreCase').Index
                $srcPos = [regex]::Match($header, 'Source', 'IgnoreCase').Index

                $updMatch = [regex]::Match($header, 'Updated', 'IgnoreCase')
                $updPos = if ($updMatch.Success) { $updMatch.Index } else { -1 }

                for ($i = $headerIdx + 2; $i -lt $raw.Count; $i++) {
                    $line = $raw[$i]
                    if ([string]::IsNullOrWhiteSpace($line) -or $line -match '^-+') { continue }
                    $name = $line.Substring(0, [Math]::Min($line.Length, $verPos)).Trim()
                    if (-not $name) { continue }
                    $ver = if ($line.Length -gt $verPos) {
                        $end = if ($srcPos -gt $verPos) { [Math]::Min($line.Length, $srcPos) } else { $line.Length }
                        $line.Substring($verPos, $end - $verPos).Trim()
                    } else { "" }
                    $bucket = if ($line.Length -gt $srcPos) {
                        $end = if ($updPos -gt $srcPos) { [Math]::Min($line.Length, $updPos) } else { $line.Length }
                        $line.Substring($srcPos, $end - $srcPos).Trim()
                    } else { "main" }
                    if (-not $bucket) { $bucket = "main" }

                    if (-not $query -or $name.Contains($query, [System.StringComparison]::OrdinalIgnoreCase)) {
                        $installed.Add([PSCustomObject]@{
                            Manager = 'scoop'
                            Bucket  = $bucket
                            Source  = $bucket
                            Id      = $name
                            Name    = $name
                            Version = $ver
                        })
                    }
                }
            }
        }
    }

    # Case 0: No installed packages match
    if ($installed.Count -eq 0) {
        gum style --foreground 214 "[-] No installed packages found matching '$query'."
        return
    }

    # Case 1: Query specified and exactly one match -> Direct confirmation
    if ($query -and $installed.Count -eq 1) {
        $target = $installed[0]
        if (-not $Force) {
            gum confirm "Are you sure you want to uninstall '$($target.Name)' ($($target.Id)) via $($target.Manager)?"
            if ($LASTEXITCODE -ne 0) {
                gum style --foreground 245 "[-] Skipped $($target.Id)."
                return
            }
        }
        Invoke-PackageUninstall -Manager $target.Manager -Id $target.Id
        return
    }

    # Multiple matches or no query: Launch fzf with Shift+? preview support
    $esc = [char]27
    $fzfLines = foreach ($item in $installed) {
        $badgeText = switch ($item.Manager) {
            'winget'  { if ($item.Source) { "winget:$($item.Source)" } else { "winget" } }
            'scoop'   { if ($item.Bucket) { "scoop:$($item.Bucket)" } else { "scoop" } }
            'msstore' { "winget:msstore" }
        }
        $badgeColor = switch ($item.Manager) {
            'winget'  { "$esc[38;5;39m" }
            'scoop'   { "$esc[38;5;214m" }
            'msstore' { "$esc[38;5;141m" }
        }
        $badge = "$badgeColor[$badgeText]$esc[0m"
        $pad = ' ' * [Math]::Max(2, 20 - ($badgeText.Length + 2))
        
        $dispId = if ($item.Id.Length -gt 40) { $item.Id.Substring(0, 39) + '…' } else { $item.Id }
        $dispVer = if ($item.Version.Length -gt 16) { $item.Version.Substring(0, 15) + '…' } else { $item.Version }

        $idPadded  = '{0,-40}' -f $dispId
        $verPadded = '{0,-16}' -f $dispVer
        $detail    = "$esc[38;5;245m$($item.Name)$esc[0m"
        $rawTarget = "$($item.Manager):$($item.Id)"
        "$rawTarget`t$badge$pad$idPadded  $verPadded  $detail"
    }

    $previewScript = Join-Path $PSScriptRoot "Get-PackageInfo.py"
    $fzfHeader = "Tab: Multi-select │ Enter: Uninstall │ ?: Info │ Esc: Cancel"
    $fzfArgs = @(
        '-m',
        '--ansi',
        '--no-hscroll',
        '--delimiter=\t',
        '--with-nth=2',
        '--nth=1,2',
        "--header=$fzfHeader",
        '--prompt=Search > ',
        '--pointer=▶',
        '--marker=✓',
        '--layout=reverse',
        '--border=rounded',
        '--preview-window=right:50%:hidden:wrap-word,<100(down:50%:hidden:wrap-word)',
        '--preview-wrap-sign=',
        "--preview=python `"$previewScript`" {1}",
        '--bind=?:toggle-preview'
    )

    if ($query) {
        $fzfArgs += "--query=$query"
    }

    $selectedLines = $fzfLines | fzf @fzfArgs

    if (-not $selectedLines -or $selectedLines.Count -eq 0) {
        gum style --foreground 245 "[-] Uninstallation cancelled. No packages selected."
        return
    }

    $toUninstall = [System.Collections.Generic.List[PSCustomObject]]::new()
    $summaryList = [System.Collections.Generic.List[string]]::new()

    foreach ($line in $selectedLines) {
        $parts = $line.Split("`t")
        $rawTarget = $parts[0].Trim()
        if ($rawTarget -match '^(?<mgr>[^:]+):(?<id>.+)$') {
            $mgr = $Matches['mgr']
            $id  = $Matches['id']
            $toUninstall.Add([PSCustomObject]@{ Manager = $mgr; Id = $id })
            $summaryList.Add("  • [$mgr] $id")
        }
    }

    if ($toUninstall.Count -eq 0) { return }

    if (-not $Force) {
        $summaryText = $summaryList -join "`n"
        gum style --border rounded --border-foreground 203 --padding "0 2" --margin "1 0" `
            "Packages To Uninstall ($($toUninstall.Count)):`n$summaryText"

        gum confirm "Proceed with uninstallation?"
        if ($LASTEXITCODE -ne 0) {
            gum style --foreground 245 "[-] Uninstallation aborted."
            return
        }
    }

    foreach ($target in $toUninstall) {
        Invoke-PackageUninstall -Manager $target.Manager -Id $target.Id
    }
}

function Update-AllPackages {
    <#
    .SYNOPSIS
        Runs the full system update pipeline across all package managers and git repos.
    .DESCRIPTION
        Updates Winget sources and binary, upgrades Winget packages, updates Scoop buckets
        and apps, upgrades UV global Python tools, pulls configured Git repositories, and
        cleans up desktop shortcut icons.
    .EXAMPLE
        Update-AllPackages
    #>
    gum style --border rounded --border-foreground 212 --padding "0 3" --margin "1 0" --bold "System Update Pipeline"

    gum style --border rounded --border-foreground 39 --margin "1 0" --padding "0 2" --bold "Updating Winget Sources & Binary"
    winget source update
    winget upgrade Microsoft.AppInstaller --accept-package-agreements --accept-source-agreements

    gum style --border rounded --border-foreground 39 --margin "1 0" --padding "0 2" --bold "Upgrading Winget Packages"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    gum style --border rounded --border-foreground 214 --margin "1 0" --padding "0 2" --bold "Updating Scoop Packages"
    scoop update
    scoop update -a
    scoop status

    # Refresh Scoop JSON index
    $scoopSearchPath = "$env:UserProfile\Git\fast-scoop-search\Scoop-Search.ps1"
    if (Test-Path $scoopSearchPath) {
        & $scoopSearchPath "__force_reindex_check__" 2>$null | Out-Null
    }

    gum style --border rounded --border-foreground 42 --margin "1 0" --padding "0 2" --bold "Upgrading UV Tools"
    uv tool upgrade --all

    gum style --border rounded --border-foreground 212 --margin "1 0" --padding "0 2" --bold "Updating Git Repositories"

    $comp = if ($global:computer) { $global:computer } else { $env:COMPUTERNAME.ToLowerInvariant() }
    $gitScriptPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\scripts\Pull-GitRepos.ps1"
    $gitConfigPath = "$env:UserProfile\Git\dotfiles\shell\pwsh\configs\git_repos_$comp.json"

    if ((Test-Path $gitScriptPath) -and (Test-Path $gitConfigPath)) {
        & $gitScriptPath -ConfigPath $gitConfigPath
    }
    else {
        gum style --foreground 214 "[-] Git pull script or config for '$comp' not found. Skipping repository updates..."
    }

    gum style --border rounded --border-foreground 245 --margin "1 0" --padding "0 2" --bold "Removing Desktop Icons"
    if (Get-Command Remove-DesktopIcons -ErrorAction SilentlyContinue) {
        Remove-DesktopIcons
    }

    gum style --border double --border-foreground 42 --margin "1 0" --padding "0 3" --bold "All packages and repositories updated successfully!"
}
