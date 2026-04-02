@echo off
TITLE Windows Automated Setup Bootstrapper
echo ==========================================
echo       Windows Setup Bootstrapper
echo ==========================================
echo.

:: 1. Define GitHub Raw URLs
:: IMPORTANT: Replace these URLs with the RAW links to your files on GitHub!
set "URL_SCRIPT=https://raw.githubusercontent.com/fahim-ahmed05/YOUR_REPO/main/setup.ps1"
set "URL_CONFIG=https://raw.githubusercontent.com/fahim-ahmed05/YOUR_REPO/main/config.json"

:: 2. Set up the temporary working directory in the USER'S Temp folder
set "SETUP_DIR=%USERPROFILE%\AppData\Local\Temp\WinSetup"
echo [INFO] Preparing temporary directory at %SETUP_DIR%...
if exist "%SETUP_DIR%" rmdir /s /q "%SETUP_DIR%"
mkdir "%SETUP_DIR%"
cd /d "%SETUP_DIR%"

:: 3. Download the files
echo [INFO] Downloading setup.ps1...
curl -sL "%URL_SCRIPT%" -o "setup.ps1"

echo [INFO] Downloading config.json...
curl -sL "%URL_CONFIG%" -o "config.json"

:: Verify downloads
if not exist "setup.ps1" (
    echo [ERROR] Failed to download setup.ps1. Please check the URL.
    pause
    exit /b 1
)
if not exist "config.json" (
    echo [ERROR] Failed to download config.json. Please check the URL.
    pause
    exit /b 1
)

:: 4. Execute the PowerShell Script and pass the config file
echo [INFO] Launching the automated setup...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1" -ConfigPath "config.json"

echo.
echo ==========================================
echo Bootstrap process complete. You can close this window.
pause