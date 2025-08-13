#Requires AutoHotkey v2.0
#SingleInstance Force

; AutoHotkey v2 - Search DuckDuckGo for selected text with F1

F1::
{
    ; Save the current clipboard contents
    savedClip := A_Clipboard

    ; Copy the selected text
    A_Clipboard := ""          ; Clear clipboard to avoid old data
    Send "^c"                  ; Copy selection
    ClipWait 0.5                ; Wait up to 0.5 sec for clipboard to contain data

    if (A_Clipboard != "") {
        ; Encode the text for a URL
        searchQuery := StrReplace(A_Clipboard, "`r`n", " ") ; Remove line breaks
        searchQuery := UriEncode(searchQuery)

        ; Open DuckDuckGo search
        Run "https://duckduckgo.com/?q=" searchQuery
    }

    ; Restore original clipboard
    A_Clipboard := savedClip
}

; Function to URL-encode a string
UriEncode(str) {
    hex := "0123456789ABCDEF"
    out := ""
    for char in StrSplit(str) {
        code := Ord(char)
        if ((code >= 0x30 && code <= 0x39)  ; 0-9
        || (code >= 0x41 && code <= 0x5A) ; A-Z
        || (code >= 0x61 && code <= 0x7A) ; a-z
        || char = "-" || char = "_" || char = "." || char = "~") {
            out .= char
        }
        else {
            out .= "%" . SubStr(hex, (code >> 4) + 1, 1) . SubStr(hex, (code & 0xF) + 1, 1)
        }
    }
    return out
}
