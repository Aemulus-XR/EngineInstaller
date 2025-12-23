@echo off
echo ========================================
echo Build Status Check
echo ========================================
echo.

echo Checking for running build processes...
echo.

REM Check for dotnet build processes
echo Looking for dotnet.exe processes:
tasklist /FI "IMAGENAME eq dotnet.exe" /FO TABLE 2>nul
echo.

REM Check for WiX Heat processes
echo Looking for heat.exe processes:
tasklist /FI "IMAGENAME eq heat.exe" /FO TABLE 2>nul
echo.

REM Check for WiX processes
echo Looking for wix.exe processes:
tasklist /FI "IMAGENAME eq wix.exe" /FO TABLE 2>nul
echo.

REM Check if build.log exists
if exist build.log (
    echo Build log exists - last 30 lines:
    echo ----------------------------------------
    powershell -Command "Get-Content build.log -Tail 30"
    echo ----------------------------------------
    echo.
    echo Full log size:
    dir build.log | find "build.log"
) else (
    echo No build.log found yet.
)
echo.

REM Check obj folder for generated files
if exist obj\x64\Release (
    echo Generated WXS files in obj\x64\Release:
    dir obj\x64\Release\_*Components_dir.wxs 2>nul
    echo.
) else (
    echo No obj\x64\Release folder found yet.
)

echo.
pause
