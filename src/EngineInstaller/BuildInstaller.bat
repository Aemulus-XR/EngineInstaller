@echo off
REM Build script for Unreal Engine Installer
REM This script builds the WiX installer MSI package

echo ========================================
echo UE 5.6 Installer Build Script
echo ========================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory so relative paths work correctly
cd /d "%SCRIPT_DIR%"

REM Set the source directory (where the engine files are)
REM Path from EngineInstaller/src/EngineInstaller to UEOculusDrop/LocalBuilds/Engine/Windows
set SOURCE_DIR=..\..\..\UEOculusDrop\LocalBuilds\Engine\Windows

REM Check if source directory exists
if not exist "%SOURCE_DIR%" (
    echo ERROR: Source directory not found: %SOURCE_DIR%
    echo.
    echo Please run GenerateInstallBuild.bat in UEOculusDrop first.
    echo.
    pause
    exit /b 1
)

echo Source directory: %SOURCE_DIR%
echo.

REM Set the SourceDir variable for WiX
set SourceDir=%SOURCE_DIR%

echo Building installer...
echo This will take 5-15 minutes for the full engine build...
echo Output will be logged to: build.log
echo Verbosity: Normal (shows progress)
echo.
echo Starting build at %TIME%...
echo.

REM Build the MSI package with verbose output
REM -v:n = normal verbosity (shows progress)
REM Can use -v:d for detailed or -v:diag for diagnostic
dotnet build -c Release -v:n > build.log 2>&1

REM Also display the log file contents to console
type build.log

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo.
echo Output: bin\x64\Release\EngineInstaller.msi
echo ========================================
echo.

pause
