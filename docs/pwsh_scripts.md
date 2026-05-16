# PowerShell Scripts

## Add-RemoveRegFiles.ps1

A PowerShell script to batch add or remove Windows registry entries from `.reg` files, organized by named groups in a JSON config.

### Features

- **Grouped registry operations**: Organize `.reg` files into named groups (e.g., `sandbox`, `alacritty`) for easier management.
- **Add and remove actions**: Support both registry import (add) and deletion (remove) operations.
- **Environment variable expansion**: Expand `%VAR%` syntax in file paths (e.g., `%USERPROFILE%\dotfiles\file.reg`).
- **Automatic UAC elevation**: Detects protected registry hives (HKLM, HKCR, HKU) and automatically relaunches elevated when needed.
- **Admin-first imports**: Groups are separated into admin-required and non-admin entries; admin entries are imported first in an elevated context.
- **Error resilience**: Failures on individual `.reg` files are logged as warnings; the script continues processing the rest.
- **Enabled/disabled groups**: Mark groups with `"enabled": false` to skip them by default; explicitly specify the group name to force processing.

### Usage

**Add registry files (default action):**
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File powershell/scripts/Add-RemoveRegFiles.ps1 -Config powershell/configs/registry-config.json sandbox
```

**Remove registry files:**
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File powershell/scripts/Add-RemoveRegFiles.ps1 -Config powershell/configs/registry-config.json -Action remove alacritty
```

**Process all enabled groups (no group names specified):**
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File powershell/scripts/Add-RemoveRegFiles.ps1 -Config powershell/configs/registry-config.json
```

**Force process a disabled group:**
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File powershell/scripts/Add-RemoveRegFiles.ps1 -Config powershell/configs/registry-config.json extras
```

### Parameters

- **`-Config`**: Path to the JSON config file (defaults to `../configs/reg_import.json` relative to the script).
- **`-Groups`**: One or more group names to process. If omitted, all enabled groups are processed.
- **`-Action`**: `add` (default) or `remove`. Determines which array (`add` or `remove`) to use from each group.
- **`-Elevated`**: Internal flag; indicates the script is running in an elevated context (avoid passing manually).
- **`-ImportAdminOnly`**: Internal flag; tells the script to only process admin-required entries (used by the elevated helper).

### Config Schema

The JSON config maps group names to group objects. Each group must have an `add` array, a `remove` array, or both. Groups can optionally have an `enabled` flag.

**Example:**
```json
{
  "sandbox": {
    "enabled": true,
    "add": [
      "%USERPROFILE%\\dotfiles\\windows_sandbox\\Sandbox.wsb.reg",
      "%USERPROFILE%\\dotfiles\\windows_sandbox\\Sandbox.usb.reg"
    ],
    "remove": [
      "%USERPROFILE%\\dotfiles\\windows_sandbox\\Sandbox.remove.reg"
    ]
  },
  "alacritty": {
    "enabled": false,
    "add": [
      "C:\\Users\\Fahim\\scoop\\apps\\alacritty\\current\\install-context.reg"
    ],
    "remove": [
      "C:\\Users\\Fahim\\scoop\\apps\\alacritty\\current\\uninstall-context.reg"
    ]
  }
}
```

### Config Fields

- **Group name** (e.g., `"sandbox"`): Top-level key identifying the group.
- **`enabled`** (optional, boolean): If `false`, the group is skipped unless explicitly requested by name. Defaults to `true`.
- **`add`** (optional, array of strings): List of `.reg` file paths to import when `-Action add` is used.
- **`remove`** (optional, array of strings): List of `.reg` file paths to import (with deletion markers) when `-Action remove` is used.

### Admin Behavior

The script detects registry hives that require administrative privileges:
- `HKEY_LOCAL_MACHINE`, `HKLM`
- `HKEY_CLASSES_ROOT`, `HKCR`
- `HKEY_USERS`, `HKU`

**Non-elevated run:**
1. Scans all `.reg` files for protected hive markers.
2. If any are found, relaunches the script elevated using `Start-Process -Verb RunAs`.
3. The elevated instance imports admin files, then returns control to the parent (non-elevated) process.
4. The parent process then imports non-admin entries (if any).

**Elevated run:**
1. Admin files are imported first.
2. Non-admin files are imported next.

### Error Handling

If a `.reg` file fails to import (missing file, access denied, etc.):
- A warning message is logged: `WARNING: Operation failed for <path> (exit code X).`
- Processing continues to the next file.
- The script does not halt or exit with an error code.

### Environment Variables

File paths support `%VAR%` expansion. Common examples:
- `%USERPROFILE%` → `C:\Users\<username>`
- `%TEMP%` → `C:\Users\<username>\AppData\Local\Temp`
- `%SYSTEMROOT%` → `C:\Windows`

### Backward Compatibility

For groups with `"enabled": true` and `-Action add`, the script falls back to a `"paths"` array if `"add"` is not present. This is for backward compatibility only; new configs should use `"add"` and `"remove"` explicitly.

### Examples

**Add sandbox registry entries:**
```powershell
pwsh -File Add-RemoveRegFiles.ps1 -Config registry-config.json sandbox
```

**Remove alacritty registry entries:**
```powershell
pwsh -File Add-RemoveRegFiles.ps1 -Config registry-config.json -Action remove alacritty
```

**Process all enabled groups (sandbox and others):**
```powershell
pwsh -File Add-RemoveRegFiles.ps1 -Config registry-config.json
```

**Force process alacritty even though it's disabled:**
```powershell
pwsh -File Add-RemoveRegFiles.ps1 -Config registry-config.json alacritty
```
