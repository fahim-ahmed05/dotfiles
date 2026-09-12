# PowerOps

A modern, interactive system power management module for PowerShell on Windows.

---

## Features

- **Interactive Menu (`power`)**: Quick keyboard-navigable power action selector powered by `gum choose`.
- **Confirmation Guards**: Protects against accidental triggers via `gum confirm` (with `-y` switch for instant execution).
- **Animated Progress Bar**: Smooth 5-second in-place terminal countdown using colored ANSI blocks (`█` and `░`).
- **Farewell Message Blink**: Calibrated blink animation (`550ms on / 350ms off`) prior to execution.
- **Fast BIOS/Firmware Reboot**: Direct reboot into UEFI/BIOS (`shutdown /r /fw /f /t 0`).

---

## Commands

| Command | Action | Quick Force Flag |
|---|---|---|
| `power` | Interactive selection menu | N/A |
| `PowerOff` | Clean system shutdown | `PowerOff -y` |
| `Reboot` | Clean system restart | `Reboot -y` |
| `Suspend` | Low-power standby sleep | `Suspend -y` |
| `Hibernate` | Save state to disk and power off | `Hibernate -y` |
| `RebootToBIOS` | Direct restart into UEFI/BIOS | `RebootToBIOS -y` |
| `Invoke-PowerAction` | Core command parameterized by `-Action` | `Invoke-PowerAction -Action Shutdown -Force` |
