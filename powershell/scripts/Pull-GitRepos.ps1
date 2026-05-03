<#
.SYNOPSIS
    Pulls updates for Git repositories based on a JSON configuration file.

.DESCRIPTION
    Reads a JSON file containing specific repo paths and folders containing multiple repos.
    Expands environment variables in paths and performs 'git pull' in each repository.

    JSON Config Example:
    {
        "repos": [
            "%USERPROFILE%\\Git\\dotfiles"
        ],
        "folders": [
            "%USERPROFILE%\\Git"
        ]
    }

.PARAMETER ConfigPath
    Path to the JSON configuration file. Defaults to 'powershell/configs/git_repos.json' relative to the dotfiles root.

.EXAMPLE
    .\Pull-GitRepos.ps1 -ConfigPath "C:\path\to\config.json"
#>

param (
    [string]$ConfigPath = "$PSScriptRoot\..\configs\git_repos.json"
)

function Expand-Path {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
    
    # Handle %VAR% and %VAR style
    $expanded = $Path
    $regex = '%([a-zA-Z0-9_]+)%?'
    
    $envMatches = [regex]::Matches($expanded, $regex)
    foreach ($match in $envMatches) {
        $varName = $match.Groups[1].Value
        $val = [System.Environment]::GetEnvironmentVariable($varName)
        if ($val) {
            $expanded = $expanded.Replace($match.Value, $val)
        }
    }
    
    return $expanded
}

function Pull-Repo {
    param([string]$RepoPath)
    
    $fullPath = Expand-Path $RepoPath
    if (-not (Test-Path $fullPath)) {
        Write-Host "[-] Path not found: $fullPath" -ForegroundColor Red
        return
    }

    if (-not (Test-Path (Join-Path $fullPath ".git"))) {
        Write-Host "[-] Not a Git repository: $fullPath" -ForegroundColor Yellow
        return
    }

    Write-Host "[*] Pulling: $fullPath" -ForegroundColor Cyan
    Push-Location $fullPath
    try {
        git pull --rebase
    } catch {
        Write-Host "[-] Failed to pull: $fullPath" -ForegroundColor Red
        Write-Error $_
    } finally {
        Pop-Location
    }
}

# Main Execution
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config file not found: $ConfigPath"
    exit 1
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

# Process specific repos
if ($config.repos) {
    foreach ($repo in $config.repos) {
        Pull-Repo $repo
    }
}

# Process folders containing multiple repos
if ($config.folders) {
    foreach ($folder in $config.folders) {
        $expandedFolder = Expand-Path $folder
        if (Test-Path $expandedFolder) {
            $subdirs = Get-ChildItem -Path $expandedFolder -Directory
            foreach ($subdir in $subdirs) {
                Pull-Repo $subdir.FullName
            }
        } else {
            Write-Host "[-] Folder not found: $expandedFolder" -ForegroundColor Red
        }
    }
}

Write-Host "[+] Pull complete!" -ForegroundColor Green
