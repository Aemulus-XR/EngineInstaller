@echo off
setlocal enabledelayedexpansion
REM Build script for Unreal Engine Installer
REM This script builds the lightweight WiX installer MSI package

echo ========================================
echo UE 5.6 Lightweight Installer Build Script
echo ========================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory so relative paths work correctly
cd /d "%SCRIPT_DIR%"

REM Check if 7za.exe exists
if not exist "Resources\7za.exe" (
    echo ERROR: 7za.exe not found in Resources folder
    echo.
    echo Please download 7-Zip Extra from https://www.7-zip.org/download.html
    echo Extract 7za.exe and place it in: Resources\7za.exe
    echo.
    pause
    exit /b 1
)

REM Check if DownloadConfig.json exists
if not exist "DownloadConfig.json" (
    echo ERROR: DownloadConfig.json not found
    echo.
    echo This file should contain the Dropbox download URL.
    echo.
    pause
    exit /b 1
)

echo Building lightweight installer...
echo This will take ~10 seconds...
echo Output will be logged to: build.log
echo.
echo Starting build at %TIME%...
echo.

REM Build the MSI package with normal verbosity
dotnet build -c Release -v:n > build.log 2>&1

REM Also display the log file contents to console
type build.log

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    echo Check build.log for details.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.

REM Get MSI size
for %%A in ("bin\x64\Release\EngineInstaller.msi") do (
    set SIZE=%%~zA
    set /a SIZE_MB=!SIZE! / 1048576
)

echo Output: bin\x64\Release\EngineInstaller.msi
echo Size: %SIZE_MB% MB
echo.
echo The installer will download the engine from Dropbox during installation.
echo Ready to test!
echo.

pause
