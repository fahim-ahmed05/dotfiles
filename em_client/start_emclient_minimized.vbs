Option Explicit

' Starts eM Client with its window kept off the screen.
'
' "cmd /c start /min" is gone: eM Client now runs as a Microsoft Store app and
' shows its own window during startup, so the /min hint is simply ignored (or
' applied to the leftover win32 launcher instead of the real process). The real
' work happens in Start-EmClientHidden.ps1 next to this file, which launches the
' app and forces its window minimized until it settles.

Dim fso, shell, here, helper, powershell, command

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

here = fso.GetParentFolderName(WScript.ScriptFullName)
helper = fso.BuildPath(here, "Start-EmClientHidden.ps1")

If Not fso.FileExists(helper) Then
    MsgBox "Helper script not found:" & vbCrLf & helper, vbCritical, "Start eM Client minimized"
    WScript.Quit 1
End If

powershell = shell.ExpandEnvironmentStrings("%SystemRoot%") & _
             "\System32\WindowsPowerShell\v1.0\powershell.exe"

' Window style 0 keeps this PowerShell run invisible, the log file makes a
' silent failure at logon debuggable later (%TEMP%\em_client_start.log).
command = """" & powershell & """ -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden" & _
          " -File """ & helper & """ -LogPath """ & _
          shell.ExpandEnvironmentStrings("%TEMP%") & "\em_client_start.log"""

shell.Run command, 0, False
