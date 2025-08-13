#Requires AutoHotkey v2.0
#SingleInstance Force

; based on: https://superuser.com/a/1538134
MoveWindowToDesktop(direction) {
  needToRevert := false
  hwnd := "ahk_id " . WinGetID("A")
  windowTitle := WinGetTitle(hwnd)
  try {
    WinSetExStyle("^0x80", hwnd)
	Send("{LWin down}{Ctrl down}{" . direction . "}{Ctrl up}{LWin up}")
	Sleep(50)
	needToRevert := true
	WinSetExStyle("^0x80", hwnd)
	WinActivate(hwnd)
  }
  catch Error as err {
	; failed to move the window.
    if (needToRevert) {
		oppositeDirection := direction = "Right" ? "Left" : "Right"
		; undo the desktop switch and notify
		Send("{LWin down}{Ctrl down}{" . oppositeDirection . "}{Ctrl up}{LWin up}")
		; TrayTip("Move failed: failed to reactivate the window '" . windowTitle . "'" , "Failed", 0x3 | 0x10)
	}
	Send("{LWin down}{Tab}{LWin up}")
	TrayTip("Move failed: '" . err.Message . "'" , "Failed", 0x3 | 0x10)
	; set the user up to manually do the switch by opening task view
	Sleep(50)
  }
}

^#Up:: {
  MoveWindowToDesktop("Left")
}

^#Down:: {
  MoveWindowToDesktop("Right")
}