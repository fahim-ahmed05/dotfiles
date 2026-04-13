@echo off
SETLOCAL EnableDelayedExpansion
TITLE Windows Automated Setup Bootstrapper

:: 1. Define Base GitHub Raw URLs
set "BASE_CONFIG_URL=https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/shell/powershell/configs/"
set "URL_SCRIPT=https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/shell/powershell/scripts/Setup-Windows.ps1"

:: 2. Set up the unified temporary working directory
set "SETUP_DIR=%TEMP%\WinSetup"
if exist "!SETUP_DIR!" rmdir /s /q "!SETUP_DIR!"
mkdir "!SETUP_DIR!"
cd /d "!SETUP_DIR!"

:INPUT_LOOP
cls
echo ==========================================
echo       Configuration Selection
echo ==========================================
echo.
echo Enter the Config Name (e.g., acer) 
echo OR paste a Direct URL (GitHub Raw or jsDelivr):
echo (Press Enter for default: setup.json)
echo.

set "USER_INPUT="
set /p USER_INPUT="Input: "

:: 1. Clean input ONLY if the user actually typed something
if defined USER_INPUT (
    set "USER_INPUT=!USER_INPUT: =!"
)

:: 2. Fallback to setup.json if empty (or if they just typed spaces)
if "!USER_INPUT!"=="" set "USER_INPUT=setup.json"

:: 3. Resolve URL logic
echo !USER_INPUT!| findstr /I "http" >nul
if !ERRORLEVEL! equ 0 (
    set "URL_CONFIG=!USER_INPUT!"
) else (
    :: Strip any existing .json extension, then cleanly append it back
    set "CLEAN_NAME=!USER_INPUT:.json=!"
    set "URL_CONFIG=!BASE_CONFIG_URL!!CLEAN_NAME!.json"
)

:: 4. Confirmation Prompt
echo.
echo ------------------------------------------
echo TARGET URL: !URL_CONFIG!
echo ------------------------------------------
echo.
set "CONFIRM="
set /p CONFIRM="Is this URL correct? (Y/N, default Y): "

if /i "!CONFIRM!"=="N" goto INPUT_LOOP

:: 5. Proceed with Download
echo.
echo [INFO] Downloading setup.ps1...
curl -sL -f -H "Cache-Control: no-cache" "!URL_SCRIPT!" -o "setup.ps1"
if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] Failed to download setup.ps1.
    pause
    exit /b 1
)

echo [INFO] Downloading configuration...
curl -sL -f -H "Cache-Control: no-cache" "!URL_CONFIG!" -o "config.json"
if !ERRORLEVEL! NEQ 0 (
    echo.
    echo [ERROR] Failed to download the config file.
    echo Please check the filename or URL and try again.
    pause
    goto INPUT_LOOP
)

:: 6. Execute
echo.
echo [INFO] Launching the automated setup...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1" -ConfigPath "config.json"

echo.
echo ==========================================
echo Bootstrap process complete.
pause