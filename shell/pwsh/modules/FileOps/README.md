# FileOps

A PowerShell utility module for system cache cleanup, safe file trashing, and automated registry management on Windows.

---

## Functions

| Function | Description | Example |
|---|---|---|
| `Add-RemoveRegFiles` | Interactive or scripted management of Windows registry tweaks | `Add-RemoveRegFiles` |
| `Clear-WindowsCache` | Purges temp directories, package caches, and empties Recycle Bin | `Clear-WindowsCache` |
| `Clear-Folder` | Moves folder contents to a safe `Trash` directory instead of permanent deletion | `Clear-Folder "Downloads"` |
| `Remove-DesktopIcons` | Moves desktop shortcut (`.lnk`) files to `Trash` | `Remove-DesktopIcons` |

---

## 1. Registry Management (`Add-RemoveRegFiles`)

### Automatic Scoop Discovery
`Add-RemoveRegFiles` automatically scans for `.reg` files provided by installed Scoop applications in `%USERPROFILE%\scoop\apps\*\current\*.reg`.
- Files matching `uninstall`, `remove`, or `disable` are categorized as **remove** actions.
- Files matching `install`, `enable`, or standard `.reg` are categorized as **add** actions.
- **No manual configuration is required** for Scoop packages (e.g. `7zip`, `alacritty`, `python`).

### Interactive Mode
When executed with no arguments, Gum provides an interactive TUI:
1. Prompts for Action: `Add (Import to Registry)` vs `Remove (Revert from Registry)`.
2. Multi-select discovered applications using `gum choose --no-limit` (`Space` to toggle, `Enter` to confirm).
3. Displays a square-bordered summary card upon completion.
4. If system-level hives (`HKLM`, `HKCR`, etc.) are detected, an elevated helper process is launched automatically.

### CLI Usage
```powershell
# Interactive mode
Add-RemoveRegFiles

# Apply specific apps non-interactively
Add-RemoveRegFiles -Groups 7zip,alacritty -Action add

# Revert specific apps non-interactively
Add-RemoveRegFiles -Groups python -Action remove

# Apply all discovered registry tweaks
Add-RemoveRegFiles -All -Action add
```

### Optional Custom Config (`reg_files.json`)
If you have custom `.reg` files outside Scoop, or want to explicitly disable a discovered Scoop package from appearing, place `reg_files.json` at `shell/pwsh/configs/reg_files.json`:

```json
{
  "custom-context-menu": {
    "enabled": true,
    "add": [
      "%USERPROFILE%\\Git\\dotfiles\\registry\\context_menu.reg"
    ],
    "remove": [
      "%USERPROFILE%\\Git\\dotfiles\\registry\\context_menu_undo.reg"
    ]
  },
  "python": {
    "enabled": false
  }
}
```

---

## 2. System Cache Cleanup (`Clear-WindowsCache`)

Clears temporary files, caches, and empties the Recycle Bin according to `shell/pwsh/configs/clear_windows_cache.json`.

### Example Config (`clear_windows_cache.json`)
```json
{
  "paths": [
    "%SYSTEMROOT%\\Prefetch",
    "%SYSTEMROOT%\\Temp",
    "%LOCALAPPDATA%\\Temp",
    "%LOCALAPPDATA%\\Package Cache",
    "%ProgramData%\\Package Cache",
    "%LOCALAPPDATA%\\pip\\cache"
  ],
  "commands": [
    "scoop cache rm -a",
    "scoop cleanup -a",
    "uv cache clean",
    "Clear-RecycleBin -Force -Confirm:$false"
  ]
}
```

---

## 3. Safe Folder Trashing (`Clear-Folder`)

Instead of permanently deleting files with `Remove-Item`, `Clear-Folder` moves items to a designated `Trash` folder (`%USERPROFILE%\Trash`) with automated collision renaming (`<name>_<timestamp>`).

Configured via machine-specific files, e.g. `shell/pwsh/configs/clear_folders_gigabyte.json`.

### Example Config (`clear_folders_<computer>.json`)
```json
{
  "trashPath": "%USERPROFILE%\\Trash",
  "sources": [
    {
      "path": "%USERPROFILE%\\Desktop"
    },
    {
      "path": "%USERPROFILE%\\Downloads",
      "exclude": ["qBittorrent"]
    }
  ],
  "trashExclude": ["DoNotDelete"]
}
```

### Usage
```powershell
# Clean configured sources (Desktop, Downloads) to Trash
Clear-Folder

# Clean only Downloads
Clear-Folder "Downloads"

# Permanently empty the Trash folder
Clear-Folder -EmptyTrash

# Clean sources and empty Trash in one command
Clear-Folder -All

# Remove empty subdirectories recursively
Clear-Folder -RemoveEmptyDirs
```
