@echo off
TITLE Windows Automated Setup Bootstrapper
echo ==========================================
echo       Windows Setup Bootstrapper
echo ==========================================
echo.

:: Prompt for the computer configuration
set "COMP_NAME="
set /p COMP_NAME="Enter computer name (e.g., acer, gigabyte) or press Enter for default: "

if "%COMP_NAME%"=="" (
    set "CONFIG_FILE=setup.json"
    echo [INFO] No name provided. Defaulting to setup.json.
) else (
    set "CONFIG_FILE=setup_%COMP_NAME%.json"
    echo [INFO] Target configuration: %CONFIG_FILE%.
)
echo.

:: 1. Define GitHub Raw URLs
set "URL_SCRIPT=https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/shell/powershell/scripts/SetupWindows.ps1"
set "URL_CONFIG=https://raw.githubusercontent.com/fahim-ahmed05/dotfiles/refs/heads/main/shell/powershell/configs/%CONFIG_FILE%"

:: 2. Set up the temporary working directory in the USER'S Temp folder
set "SETUP_DIR=%USERPROFILE%\AppData\Local\Temp\WinSetup"
echo [INFO] Preparing temporary directory at %SETUP_DIR%...
if exist "%SETUP_DIR%" rmdir /s /q "%SETUP_DIR%"
mkdir "%SETUP_DIR%"
cd /d "%SETUP_DIR%"

:: 3. Download the files
echo [INFO] Downloading setup.ps1...
:: The -f flag forces curl to fail silently on HTTP errors (like 404 Not Found)
curl -sL -f "%URL_SCRIPT%" -o "setup.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to download setup.ps1. Please check the script URL.
    pause
    exit /b 1
)

echo [INFO] Downloading %CONFIG_FILE%...
curl -sL -f "%URL_CONFIG%" -o "config.json"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to download %CONFIG_FILE%. Make sure the config file exists in your GitHub repo!
    pause
    exit /b 1
)

:: 4. Execute the PowerShell Script and pass the config file
echo.
echo [INFO] Launching the automated setup...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1" -ConfigPath "config.json"

echo.
echo ==========================================
echo Bootstrap process complete. You can close this window.
pause