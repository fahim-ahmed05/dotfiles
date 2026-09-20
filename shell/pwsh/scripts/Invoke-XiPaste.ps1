<#
.SYNOPSIS
    xipe - CLI client for the xi.pe pastebin (https://xi.pe).
.DESCRIPTION
    Create, view, download, inspect and delete xi.pe pastes.

    xi.pe is plain-text only (UTF-8), max 2 MiB, pastes expire after 7 days by
    default, and anyone with the URL can read the paste - never upload secrets.

    Create (default action):
        xipe file.txt                     Upload a file
        xipe file.txt -Long               23-char code instead of 6 (harder to guess)
        xipe file.txt -Ttl 1h             Expire sooner than the 7-day default (m/h/d)
        xipe -Text "hello world"          Upload literal text
        Get-Content log.txt -Raw | xipe   Upload from the pipeline
        xipe file.txt -Lang powershell    Returned link opens with syntax highlighting
        xipe notes.md -Lang md            Returned link renders as Markdown

    Other actions:
        xipe view nZNxdT [-Lang ps1]      Print a paste (bat syntax highlighting if installed)
        xipe dl nZNxdT [-OutFile out.txt] Download a paste (default: .\<code>.txt)
        xipe info nZNxdT                  Existence check + created/expires timestamps
        xipe rm nZNxdT                    Delete a paste (uses stored or given -Token)
        xipe rm                           Pick a paste to delete via fzf
        xipe tokens                       List stored delete tokens (expired auto-pruned)
        xipe help                         Show usage

    Delete tokens: captured automatically on upload and stored in
    ~\.local\share\xipe\tokens.json, so 'xipe rm <code>' just works. Expired
    tokens are pruned automatically. Run 'xipe rm' or 'xipe tokens' with no
    code to pick a paste interactively via fzf (when installed).
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$Target,

    # Create options
    [string]$Text,
    [switch]$Long,
    [ValidatePattern('^\d+[mhd]$')]
    [string]$Ttl,

    # Shared: highlight language for view, or share-link suffix for create
    # ('md' renders markdown in the browser)
    [string]$Lang,

    # Download option
    [string]$OutFile,

    # Delete option
    [string]$Token,

    # Piped content
    [Parameter(ValueFromPipeline = $true)]
    [string]$PipelineInput
)

begin {
    $ErrorActionPreference = 'Stop'
    $baseUrl = 'https://xi.pe'
    $tokenStorePath = "$env:UserProfile\.local\share\xipe\tokens.json"
    $script:hasGum = [bool](Get-Command gum -ErrorAction SilentlyContinue)
    $script:hasFzf = [bool](Get-Command fzf -ErrorAction SilentlyContinue)
    $script:pipeBuffer = [System.Text.StringBuilder]::new()
    $script:hasTextParam = $PSBoundParameters.ContainsKey('Text')

    function Write-XiNote([string]$Message, [int]$Color = 245) {
        if ($script:hasGum) { gum style --foreground $Color $Message }
        else { Write-Host $Message }
    }

    function Write-XiError([string]$Message) {
        if ($script:hasGum) { gum style --foreground 203 "[-] $Message" }
        else { Write-Host "[-] $Message" -ForegroundColor Red }
    }

    function Resolve-XiCode([string]$InputValue) {
        # Accepts a bare code, a full xi.pe URL, or a view-suffixed URL.
        if ($InputValue -match 'xi\.pe/([A-Za-z0-9]+)') { return $Matches[1] }
        if ($InputValue -match '^[A-Za-z0-9]{6,32}$') { return $InputValue }
        return $null
    }

    function Get-XiTokens {
        if (Test-Path $tokenStorePath) {
            try { $store = Get-Content $tokenStorePath -Raw | ConvertFrom-Json } catch { return $null }
            if ($null -eq $store) { return $null }
            # Prune entries whose expiry has already passed; persist if anything changed.
            $now = [DateTime]::UtcNow
            $expired = [System.Collections.Generic.List[string]]::new()
            foreach ($prop in $store.PSObject.Properties) {
                $exp = [DateTime]::MinValue
                $raw = $prop.Value.expires
                if ($raw -is [array]) { $raw = $raw[0] }
                if ($raw -and [DateTime]::TryParse([string]$raw, [ref]$exp) -and $exp.ToUniversalTime() -le $now) {
                    $expired.Add($prop.Name)
                }
            }
            if ($expired.Count) {
                foreach ($name in $expired) { $store.PSObject.Properties.Remove($name) }
                Write-XiTokens $store
            }
            return $store
        }
        return $null
    }

    function Write-XiTokens($Store) {
        $json = $Store | ConvertTo-Json -Depth 4
        for ($attempt = 0; $attempt -lt 5; $attempt++) {
            try {
                [System.IO.File]::WriteAllText($tokenStorePath, $json, [System.Text.UTF8Encoding]::new($false))
                return
            }
            catch [System.IO.IOException] { Start-Sleep -Milliseconds 100 }
        }
    }

    function Save-XiToken([string]$Code, [string]$TokenValue, [string]$Expires) {
        $store = Get-XiTokens
        if ($null -eq $store) { $store = [pscustomobject]@{} }
        $store | Add-Member -NotePropertyName $Code -NotePropertyValue ([pscustomobject]@{
                token   = $TokenValue
                created = (Get-Date).ToUniversalTime().ToString('o')
                expires = $Expires
            }) -Force
        $storeDir = Split-Path $tokenStorePath
        if (-not (Test-Path $storeDir)) { New-Item -ItemType Directory -Path $storeDir -Force | Out-Null }
        Write-XiTokens $store
    }

    function Remove-XiToken([string]$Code) {
        $store = Get-XiTokens
        if ($store -and $store.PSObject.Properties.Name -contains $Code) {
            $store.PSObject.Properties.Remove($Code)
            Write-XiTokens $store
        }
    }

    function Get-XiContent([string]$Code) {
        # Always fetch plain text; view params (?md/?h=) only affect browser rendering.
        $resp = Invoke-WebRequest -Uri "$baseUrl/$Code`?raw" -TimeoutSec 15 -ErrorAction Stop
        return $resp.Content
    }
}

process {
    if ($null -ne $PipelineInput) { [void]$script:pipeBuffer.AppendLine($PipelineInput) }
}

end {
    function Invoke-XiCreate {
        if ($script:hasTextParam) {
            $content = $Text
            $sourceDesc = 'inline text'
        }
        elseif ($Target) {
            if (-not (Test-Path $Target -PathType Leaf)) {
                Write-XiError "File path does not exist: $Target"
                return
            }
            $content = Get-Content $Target -Raw
            $sourceDesc = $Target
        }
        elseif ($script:pipeBuffer.Length -gt 0) {
            $content = $script:pipeBuffer.ToString().TrimEnd("`r", "`n")
            $sourceDesc = 'stdin'
        }
        else {
            Write-XiError "Nothing to upload. Pass a file path, -Text, or pipe content in. Try: xipe help"
            return
        }

        if ([string]::IsNullOrEmpty($content)) {
            Write-XiError "Nothing to upload (content is empty)."
            return
        }
        $utf8Bytes = [System.Text.Encoding]::UTF8.GetByteCount($content)
        if ($utf8Bytes -gt 2MB) {
            Write-XiError "Content is $([math]::Round($utf8Bytes / 1MB, 2)) MiB; xi.pe allows at most 2 MiB."
            return
        }

        $query = @()
        if ($Long) { $query += 'long' }
        if ($Ttl) { $query += "ttl=$Ttl" }
        $uri = $baseUrl + '/'
        if ($query.Count) { $uri += '?' + ($query -join '&') }

        Write-XiNote "Uploading $sourceDesc to xi.pe..."
        try {
            $resp = Invoke-WebRequest -Uri $uri -Method Post -Body $content -TimeoutSec 30 -ErrorAction Stop
        }
        catch {
            Write-XiError "Failed to upload: $($_.Exception.Message)"
            return
        }

        $url = ([string]$resp.Content).Trim()
        $expires = [string]$resp.Headers['X-Paste-Expires']
        $deleteToken = [string]$resp.Headers['X-Delete-Token']
        $code = Resolve-XiCode $url

        if ($deleteToken -and $code) { Save-XiToken -Code $code -TokenValue $deleteToken -Expires $expires }

        # xi.pe renders in browsers per suffix; ?md is markdown, ?h=<lang> is syntax highlight.
        $shareUrl = $url
        if ($Lang) {
            $shareUrl += if ($Lang -eq 'md') { '?md' } else { "?h=$Lang" }
        }
        Set-Clipboard $shareUrl

        $expiryNote = if ($expires) { "expires $expires" } else { 'expires in 7 days' }
        if ($script:hasGum) {
            gum style --border normal --border-foreground 42 --padding "0 2" `
                "Uploaded to xi.pe!" `
                "URL : $shareUrl (copied to clipboard, $expiryNote)"
        }
        else {
            Write-Output "$shareUrl copied to clipboard ($expiryNote)."
        }
    }

    function Invoke-XiView {
        $code = Resolve-XiCode $Target
        if (-not $code) { Write-XiError "Not a valid xi.pe code or URL: $Target"; return }

        try { $content = Get-XiContent $code }
        catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 404) { Write-XiError "Paste not found or expired: $code" }
            else { Write-XiError "Failed to fetch paste: $($_.Exception.Message)" }
            return
        }

        $bat = Get-Command bat -ErrorAction SilentlyContinue
        if ($bat -and -not [Console]::IsOutputRedirected) {
            $tmp = Join-Path $env:TEMP "xi-$code.txt"
            [System.IO.File]::WriteAllText($tmp, $content, [System.Text.UTF8Encoding]::new($false))
            try {
                if ($Lang) { & $bat.Source --paging=never --language $Lang $tmp }
                else { & $bat.Source --paging=never $tmp }
            }
            finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
        }
        else {
            Write-Output $content
        }
    }

    function Invoke-XiDownload {
        $code = Resolve-XiCode $Target
        if (-not $code) { Write-XiError "Not a valid xi.pe code or URL: $Target"; return }

        $dest = if ($OutFile) { $OutFile } else { Join-Path (Get-Location).Path "$code.txt" }
        try {
            Invoke-WebRequest -Uri "$baseUrl/$code`?raw" -OutFile $dest -TimeoutSec 30 -ErrorAction Stop
        }
        catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 404) { Write-XiError "Paste not found or expired: $code" }
            else { Write-XiError "Failed to download paste: $($_.Exception.Message)" }
            return
        }
        Write-XiNote "[+] Saved to $dest" 42
    }


    function Invoke-XiInfo {
        $code = Resolve-XiCode $Target
        if (-not $code) { Write-XiError "Not a valid xi.pe code or URL: $Target"; return }

        try {
            $resp = Invoke-WebRequest -Uri "$baseUrl/$code" -Method Head -TimeoutSec 15 -ErrorAction Stop
            $created = $resp.Headers['X-Paste-Created']
            $expires = $resp.Headers['X-Paste-Expires']
            if ($script:hasGum) {
                gum style --border normal --border-foreground 39 --padding "0 2" `
                    "Paste   : $baseUrl/$code" `
                    "Status  : exists" `
                    "Created : $created" `
                    "Expires : $expires"
            }
            else {
                Write-Output "Paste   : $baseUrl/$code"
                Write-Output "Status  : exists"
                Write-Output "Created : $created"
                Write-Output "Expires : $expires"
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode.value__ -eq 404) { Write-XiError "Paste not found or expired: $code" }
            else { Write-XiError "Failed to check paste: $($_.Exception.Message)" }
        }
    }

    # Opens an fzf picker over stored tokens; sets $script:Target to the chosen code.
    # Returns $true if a code was picked, $false to abort.
    function Select-XiCode([string]$PromptLabel) {
        $store = Get-XiTokens
        if (-not $store -or -not $store.PSObject.Properties.Count) {
            Write-XiNote 'No stored delete tokens.'
            return $false
        }
        if (-not $script:hasFzf) {
            Show-XiTokens
            Write-XiNote 'Pass a code explicitly, e.g.: xipe rm <code>'
            return $false
        }
        $lines = foreach ($prop in $store.PSObject.Properties) {
            "{0}  expires {1}" -f $prop.Name, $prop.Value.expires
        }
        $picked = $lines | fzf --prompt "$PromptLabel> " --height 40% --reverse
        if (-not $picked) { return $false }  # Esc / Ctrl-C
        $script:Target = ($picked -split '\s+')[0]
        return $true
    }

    function Invoke-XiDelete {
        if (-not $Target -and -not (Select-XiCode 'delete')) { return }
        $code = Resolve-XiCode $Target
        if (-not $code) { Write-XiError "Not a valid xi.pe code or URL: $Target"; return }

        if (-not $Token) {
            $store = Get-XiTokens
            $entry = if ($store) { $store.PSObject.Properties[$code] } else { $null }
            if ($entry) { $Token = $entry.Value.token }
        }
        if (-not $Token) {
            Write-XiError "No delete token for '$code'. Tokens are captured at upload time; pass one explicitly with -Token."
            return
        }

        $status = $null
        try {
            Invoke-WebRequest -Uri "$baseUrl/$code" -Method Delete -Headers @{ 'X-Delete-Token' = $Token } -TimeoutSec 15 -ErrorAction Stop | Out-Null
        }
        catch {
            $status = $_.Exception.Response.StatusCode.value__
        }

        if ($null -eq $status) {
            Remove-XiToken $code
            Write-XiNote "[+] Deleted $baseUrl/$code" 42
        }
        elseif ($status -eq 401) {
            Remove-XiToken $code
            Write-XiError "Stored token for '$code' was rejected (already deleted, expired, or invalid). Removed it locally."
        }
        elseif ($status -eq 404) {
            Remove-XiToken $code
            Write-XiError "Paste not found or expired: $code (removed stale token)."
        }
        else {
            Write-XiError "Failed to delete paste (HTTP $status)."
        }
    }

    function Show-XiTokens {
        $store = Get-XiTokens
        if (-not $store -or -not $store.PSObject.Properties.Count) {
            Write-XiNote "No stored delete tokens."
            return
        }
        foreach ($prop in $store.PSObject.Properties) {
            Write-Output "$($prop.Name)  ($baseUrl/$($prop.Name))  expires: $($prop.Value.expires)"
        }
    }

    function Show-XiHelp {
        $helpText = @'
xipe - CLI client for the xi.pe pastebin (plain-text only, max 2 MiB, 7-day default expiry)

CREATE (default action)
  xipe <file>                       Upload a file, copy URL to clipboard
  xipe <file> -Long                 Use a 23-char code instead of 6 (harder to guess)
  xipe <file> -Ttl 1h               Shorter lifetime: number + m(inutes)/h(ours)/d(ays)
  xipe -Text "hello"                Upload literal text
  ... | xipe                        Upload piped content
  xipe <file> -Lang powershell      Share link opens with syntax highlighting
  xipe notes.md -Lang md            Share link renders Markdown (mermaid supported)

VIEW / DOWNLOAD / INFO
  xipe view <code|url>              Print paste (bat highlighting if installed, plain otherwise)
  xipe view <code> -Lang ps1        Force a bat language for highlighting
  xipe dl <code> [-OutFile f.txt]   Download paste (default: .\<code>.txt)
  xipe info <code>                  Existence check + created/expires timestamps

DELETE
  xipe rm <code>                    Delete using the token stored at upload time
  xipe rm                           Pick a paste to delete interactively (fzf)
  xipe rm <code> -Token <token>     Delete using an explicit token
  xipe tokens                       List stored delete tokens (expired ones auto-pruned)

Tokens are stored in ~\.local\share\xipe\tokens.json
WARNING: anyone with the URL can read a paste. Never upload secrets.
'@
        if ($script:hasGum) { gum style --border normal --border-foreground 212 --padding "0 2" $helpText }
        else { Write-Output $helpText }
    }

    switch -Regex ($Action) {
        '^(create|new|upload)$'    { Invoke-XiCreate; break }
        '^(view|show|read|get)$'   { Invoke-XiView; break }
        '^(dl|download)$'          { Invoke-XiDownload; break }
        '^(info|head|check)$'      { Invoke-XiInfo; break }
        '^(rm|del|delete)$'        { Invoke-XiDelete; break }
        '^tokens$'                 { Show-XiTokens; break }
        { $_ -in 'help', 'h', '?' } { Show-XiHelp; break }
        default {
            # 'xipe file.txt' shorthand: first word is a path/text target, not an action
            if ($Action) { $script:Target = $Action }
            Invoke-XiCreate
        }
    }
}
