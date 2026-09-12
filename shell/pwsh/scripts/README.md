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

---

## Stop-GitHubAction.ps1

A context-aware tool to stop/cancel running or queued GitHub Actions workflows.

### Features
- **Git Context Awareness**: Automatically extracts the repository `Owner` and `Repo` name from `git remote get-url origin` when run inside a local repository.
- **Automatic Token Resolution**: Resolves authentication automatically via `gh auth token`, `$env:GH_TOKEN`, or `$env:GITHUB_TOKEN`.
- **Interactive Workflow Selector**: If `-RunId` is omitted, lists active/queued workflow runs and allows you to pick one with `gum choose` or `fzf`.
- **Zero-Emoji Output**: Renders clean feedback in square-bordered Gum summary cards.

### Usage
```powershell
# Interactive run picker for current repository
pwsh Stop-GitHubAction.ps1

# Cancel a specific run in current repository
pwsh Stop-GitHubAction.ps1 -RunId 123456789

# Explicit owner/repo and force cancel
pwsh Stop-GitHubAction.ps1 -Owner octocat -Repo hello-world -RunId 123456789 -Force
```

> **Note**: The legacy `Cancel-GitHubAction.ps1` remains available for scripts that invoke it directly with mandatory parameters.

---

## Pull-GitRepos.ps1

Pulls updates for multiple Git repositories in parallel with automatic machine configuration resolution and safety checks.

### Features
- **Machine Config Auto-Detection**: Automatically detects your computer name (e.g. `git_repos_acer.json`, `git_repos_gigabyte.json`), falling back to `git_repos.json` or scanning `$env:USERPROFILE\Git`.
- **Parallel Pulling**: Performs `git pull --rebase` across multiple repositories concurrently (configurable `-Parallel`, default 4).
- **Worktree Safety Guards**: Checks `git status --porcelain` and safely skips repos with uncommitted changes (`Skipped (Dirty)`), preventing merge/rebase conflicts.
- **Remote Upstream Check**: Skips branches that do not have an upstream remote tracking branch.
- **Summary Card**: Renders a square-bordered Gum status card summarizing total, updated, up-to-date, skipped, and failed repositories.

### Usage
```powershell
# Auto-discover and pull all repos
pwsh Pull-GitRepos.ps1

# Dry-run to inspect repositories without pulling
pwsh Pull-GitRepos.ps1 -DryRun

# Custom parallelism and explicit config
pwsh Pull-GitRepos.ps1 -Parallel 6 -ConfigPath "..\configs\git_repos_custom.json"
```

---

## Download-Audiobook.ps1

A high-performance interactive audiobook downloader and metadata processor utilizing `yt-dlp`, `fzf`, `ffmpeg`, and `gum`.

### Features
- **Interactive Navigation**: Powered by `gum choose` and `fzf` for selecting modes (Single, Multi-part, Channel, Playlist) and tracks.
- **In-Place Progress Bars**: Custom multi-slot terminal engine (`Update-TerminalLine`) displaying live download speeds, percentages, and ETAs with ANSI block characters.
- **Audio Conversion & Tagging**: Extracts audio to `.m4a`, crops thumbnails to square aspect ratio using ffmpeg, and injects complete ID3 metadata (Title, Artist, Album, Track Number).
- **Resume & Retry**: Allows re-trying failed downloads interactively at the end of a batch.

### Usage
```powershell
# Launch interactive mode
pwsh Download-Audiobook.ps1
```

