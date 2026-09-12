<#
.SYNOPSIS
    PowerOps - System Power Management Module
.DESCRIPTION
    Provides modern, interactive power management actions (Shutdown, Reboot, Suspend,
    Hibernate, Firmware/BIOS) with Gum confirmation, animated progress bar countdown,
    blinking farewell messaging, and an interactive 'power' selection menu.
#>

function Invoke-PowerAction {
    <#
    .SYNOPSIS
        Executes a system power action with confirmation and animated countdown.
    .PARAMETER Action
        The power action to perform: Shutdown, Reboot, Suspend, Hibernate, or Firmware.
    .PARAMETER Force
        Bypasses confirmation prompts.
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Shutdown', 'Reboot', 'Suspend', 'Hibernate', 'Firmware')]
        [string]$Action,
        [switch]$Force
    )

    $doAction = $false
    if ($Force) {
        $doAction = $true
    }
    else {
        $verb = if ($Action -eq 'Firmware') { "reboot to BIOS" } else { $Action.ToLower() }
        if (Get-Command gum -ErrorAction SilentlyContinue) {
            gum confirm "Are you sure you want to $verb the computer?"
            if ($LASTEXITCODE -eq 0) {
                $doAction = $true
            }
        }
        else {
            $answer = Read-Host "Are you sure you want to $verb the computer? (y/n)"
            if ($answer -eq "y") {
                $doAction = $true
            }
            else {
                Write-Host "$Action cancelled."
            }
        }
    }

    if ($doAction) {
        $verb = switch ($Action) {
            'Firmware'  { "Rebooting to BIOS" }
            'Shutdown'  { "Shutting down" }
            'Reboot'    { "Rebooting" }
            'Suspend'   { "Suspending" }
            'Hibernate' { "Hibernating" }
        }

        $color = switch ($Action) {
            'Shutdown'  { 203 } # Coral/Red
            'Reboot'    { 214 } # Gold/Orange
            'Firmware'  { 141 } # Violet
            default     { 39 }  # Cyan
        }

        $farewell = switch ($Action) {
            'Shutdown' { "Good bye!" }
            'Firmware' { "Happy tinkering!" }
            default    { "See you soon!" }
        }

        $esc = [char]27
        $barWidth = 20

        for ($i = 5; $i -gt 0; $i--) {
            $pct = (5 - $i) / 5
            $filled = [int]($pct * $barWidth)
            $empty = $barWidth - $filled
            $bar = "$esc[38;5;${color}m" + ("█" * $filled) + "$esc[38;5;238m" + ("░" * $empty) + "$esc[0m"
            Write-Host -NoNewline "`r  $esc[1m$verb$esc[0m in ${i}s  [$bar] "
            Start-Sleep -Seconds 1
        }

        $fullBar = "$esc[38;5;${color}m" + ("█" * $barWidth) + "$esc[0m"
        $blank = " " * ($farewell.Length + 4)
        $lineWithFarewell = "`r  $esc[1m$verb$esc[0m in 0s  [$fullBar]  $esc[38;5;${color}m$farewell$esc[0m    "
        $lineWithoutFarewell = "`r  $esc[1m$verb$esc[0m in 0s  [$fullBar]  $blank"

        # Relaxed farewell blink (550ms on / 350ms off)
        1..2 | ForEach-Object {
            Write-Host -NoNewline $lineWithFarewell
            Start-Sleep -Milliseconds 550
            Write-Host -NoNewline $lineWithoutFarewell
            Start-Sleep -Milliseconds 350
        }
        Write-Host $lineWithFarewell
        Start-Sleep -Milliseconds 800
        
        switch ($Action) {
            'Shutdown'  { shutdown /s /f /t 0 }
            'Reboot'    { shutdown /r /f /t 0 }
            'Firmware'  { shutdown /r /fw /f /t 0 }
            'Suspend'   { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false) }
            'Hibernate' { Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.Application]::SetSuspendState('Hibernate', $false, $false) }
        }
    }
}

function PowerOff     { [CmdletBinding()] param([switch]$y) Invoke-PowerAction -Action Shutdown  -Force:$y }
function Reboot       { [CmdletBinding()] param([switch]$y) Invoke-PowerAction -Action Reboot    -Force:$y }
function Suspend      { [CmdletBinding()] param([switch]$y) Invoke-PowerAction -Action Suspend   -Force:$y }
function Hibernate    { [CmdletBinding()] param([switch]$y) Invoke-PowerAction -Action Hibernate -Force:$y }
function RebootToBIOS { [CmdletBinding()] param([switch]$y) Invoke-PowerAction -Action Firmware  -Force:$y }

function power {
    <#
    .SYNOPSIS
        Interactive system power menu powered by gum.
    #>
    if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
        Write-Host "gum is required for the interactive power menu." -ForegroundColor Red
        return
    }

    $choice = gum choose --cursor="▶ " --cursor.foreground 214 "Shutdown" "Reboot" "Suspend" "Hibernate" "Reboot to BIOS"
    if (-not $choice) { return }

    $action = if ($choice -eq "Reboot to BIOS") { "Firmware" } else { $choice }
    Invoke-PowerAction -Action $action
}

Export-ModuleMember -Function Invoke-PowerAction, PowerOff, Reboot, Suspend, Hibernate, RebootToBIOS, power
