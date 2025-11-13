# .\Force-Cancel-GitHubRun.ps1 -Owner "name/username" -Repo "repo_name" -RunId 123456789 -Token "ghp_token"

param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [Parameter(Mandatory = $true)]
    [string]$Repo,

    [Parameter(Mandatory = $true)]
    [long]$RunId,

    [Parameter(Mandatory = $true)]
    [string]$Token
)

$uri = "https://api.github.com/repos/$Owner/$Repo/actions/runs/$RunId/force-cancel"

$headers = @{
    "Accept"               = "application/vnd.github+json"
    "Authorization"        = "Bearer $Token"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# PowerShell's Invoke-RestMethod is more idiomatic than curl
Invoke-RestMethod -Uri $uri -Method Post -Headers $headers
