@echo off
REM Build script for Aemulus-XR Unreal Engine Installer
REM This script builds the WiX installer MSI package

echo ========================================
echo Aemulus-XR UE 5.6 Installer Build Script
echo ========================================
echo.

REM Set the source directory (where the engine files are)
set SOURCE_DIR=..\..\..\..\..\UEOculusDrop\LocalBuilds\Engine\Windows

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
echo.

REM Build the MSI package
dotnet build -c Release

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
echo Output: bin\Release\net9.0\en-US\AemulusEngineInstaller.msi
echo ========================================
echo.

pause
