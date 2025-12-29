@echo off
setlocal enabledelayedexpansion
REM Wrapper script to run Install-Engine.ps1
REM Parameters: %1 = Pipe-delimited: InstallerResourcesFolder|INSTALLFOLDER

REM Log everything to file in project directory
set "BATCH_LOG=E:\1\GitRepos\Aemulus-XR\EngineInstaller\UEInstaller_Batch.log"
echo Starting batch script at %DATE% %TIME% > "%BATCH_LOG%"
echo Raw parameter received: %1 >> "%BATCH_LOG%"

echo ========================================
echo UE 5.6 Installation Script
echo ========================================
echo.
echo DEBUG: Batch script started >> "%BATCH_LOG%"
echo DEBUG: Script started
echo DEBUG: Raw parameter: %1
echo DEBUG: Batch log: %BATCH_LOG%
echo.

REM Split the parameter by pipe
set "PARAMS=%~1"
for /f "tokens=1,2 delims=|" %%a in ("%PARAMS%") do (
    set "RESOURCES_FOLDER=%%a"
    set "INSTALL_FOLDER=%%b"
)

echo Parameters received:
echo   Installer Resources: !RESOURCES_FOLDER!
echo   Install Folder: !INSTALL_FOLDER!
echo.
echo Running PowerShell installation script...
echo Batch log: %BATCH_LOG%
echo PowerShell log: E:\1\GitRepos\Aemulus-XR\EngineInstaller\UEInstaller.log
echo.

REM Set environment variables for PowerShell to read
set "PS_INSTALL_FOLDER=!INSTALL_FOLDER!"
set "PS_MSI_PATH=!RESOURCES_FOLDER!"

powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "& '%PS_MSI_PATH%Install-Engine.ps1' -InstallFolder $env:PS_INSTALL_FOLDER -MSIPath $env:PS_MSI_PATH"

set INSTALL_EXIT=%ERRORLEVEL%

echo.
echo Script completed with exit code: %INSTALL_EXIT%
echo.

if %INSTALL_EXIT% NEQ 0 (
    echo ERROR: Installation failed!
    echo Check log file at: %TEMP%\UEInstaller.log
    echo.
) else (
    echo Installation completed successfully!
    echo.
)

pause
exit /b %INSTALL_EXIT%
