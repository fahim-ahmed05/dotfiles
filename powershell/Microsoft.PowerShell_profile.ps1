# Custom Fucntions and Aliases
$functionsRoot = "C:\Users\Fahim\GitHub\dotfiles\powershell\functions"

. "$functionsRoot\ShellHooks.ps1"
. "$functionsRoot\CustomFunctions.ps1"
. "$functionsRoot\UnixLikeCommands.ps1"
. "$functionsRoot\PackageManagement.ps1"
. "$functionsRoot\CleanupTools.ps1"

# Prompt
oh-my-posh init pwsh --config 'C:\Users\Fahim\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json' | Invoke-Expression

# PSReadLine
$PSReadLineOptions = @{
    EditMode                      = 'Windows'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
        Command   = '#87CEEB'  # SkyBlue
        Parameter = '#98FB98'  # PaleGreen
        Operator  = '#FFB6C1'  # LightPink
        Variable  = '#DDA0DD'  # Plum
        String    = '#FFDAB9'  # PeachPuff
        Number    = '#B0E0E6'  # PowderBlue
        Type      = '#F0E68C'  # Khaki
        Comment   = '#D3D3D3'  # LightGray
        Keyword   = '#8367c7'  # Violet
        Error     = '#FF6347'  # Red
    }
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    BellStyle                     = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000




