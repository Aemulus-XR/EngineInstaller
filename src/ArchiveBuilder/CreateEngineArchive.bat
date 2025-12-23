@echo off
REM ========================================
REM Aemulus-XR Engine Archive Builder
REM ========================================
REM This script:
REM 1. Cleans the engine build folder (removes temp/cache files)
REM 2. Creates a 7z archive for distribution
REM 3. Reports the archive size and location
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo Aemulus-XR Engine Archive Builder
echo ========================================
echo.

REM Get script directory
set SCRIPT_DIR=%~dp0

REM Define paths
set ENGINE_SOURCE=..\..\..\..\UEOculusDrop\LocalBuilds\Engine\Windows
set OUTPUT_DIR=%SCRIPT_DIR%Output
set ARCHIVE_NAME=UE_5.6_OculusDrop.7z
set LOG_FILE=%SCRIPT_DIR%archive_build.log

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Check if source exists
if not exist "%ENGINE_SOURCE%" (
    echo ERROR: Engine source not found: %ENGINE_SOURCE%
    echo.
    echo Please run GenerateInstallBuild.bat in UEOculusDrop first.
    pause
    exit /b 1
)

echo Engine source: %ENGINE_SOURCE%
echo Output directory: %OUTPUT_DIR%
echo Archive name: %ARCHIVE_NAME%
echo.

REM ========================================
REM Step 1: Clean the engine folder
REM ========================================
echo Step 1: Cleaning engine folder...
echo ----------------------------------------
echo Removing temporary and cache files...
echo.

set FOLDERS_TO_DELETE=Intermediate DerivedDataCache Saved\Logs Saved\Crashes

for %%F in (%FOLDERS_TO_DELETE%) do (
    if exist "%ENGINE_SOURCE%\Engine\%%F" (
        echo   Deleting Engine\%%F...
        rd /s /q "%ENGINE_SOURCE%\Engine\%%F" 2>nul
    )
)

REM Also clean Intermediate from Templates and Samples
echo   Cleaning Templates...
for /d %%D in ("%ENGINE_SOURCE%\Templates\*") do (
    if exist "%%D\Intermediate" (
        echo     Deleting %%~nxD\Intermediate...
        rd /s /q "%%D\Intermediate" 2>nul
    )
)

echo   Cleaning Samples...
for /d %%D in ("%ENGINE_SOURCE%\Samples\*") do (
    if exist "%%D\Intermediate" (
        echo     Deleting %%~nxD\Intermediate...
        rd /s /q "%%D\Intermediate" 2>nul
    )
)

echo.
echo Cleanup complete!
echo.

REM ========================================
REM Step 2: Create 7z archive
REM ========================================
echo Step 2: Creating 7z archive...
echo ----------------------------------------
echo This may take 10-20 minutes depending on file size...
echo Start time: %TIME%
echo.

REM Check if 7z is available
where 7z >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: 7z.exe not found in PATH
    echo.
    echo Please install 7-Zip and add it to your PATH, or run this from the 7-Zip installation directory.
    echo Download: https://www.7-zip.org/
    pause
    exit /b 1
)

REM Create archive with maximum compression
REM -t7z = 7z format
REM -mx=9 = maximum compression
REM -ms=on = solid archive (better compression)
REM -mmt=on = multithreaded
echo Creating archive: %OUTPUT_DIR%\%ARCHIVE_NAME%
echo.

7z a -t7z -mx=9 -ms=on -mmt=on "%OUTPUT_DIR%\%ARCHIVE_NAME%" "%ENGINE_SOURCE%\*" > "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: 7z archive creation failed!
    echo Check log file: %LOG_FILE%
    pause
    exit /b 1
)

echo.
echo End time: %TIME%
echo.

REM ========================================
REM Step 3: Report results
REM ========================================
echo ========================================
echo Archive Created Successfully!
echo ========================================
echo.

REM Get file size
for %%A in ("%OUTPUT_DIR%\%ARCHIVE_NAME%") do (
    set SIZE=%%~zA
    set /a SIZE_MB=!SIZE! / 1048576
    set /a SIZE_GB=!SIZE_MB! / 1024
    echo Archive: %%~fA
    echo Size: !SIZE_MB! MB ^(!SIZE_GB! GB^)
)

echo.
echo ========================================
echo Next Steps:
echo ========================================
echo 1. Upload %ARCHIVE_NAME% to Google Drive
echo 2. Share with "Anyone with the link"
echo 3. Get the direct download link:
echo    - Right-click file in Google Drive
echo    - Get link
echo    - Change sharing to "Anyone with the link"
echo    - Copy the file ID from the URL
echo    - Use format: https://drive.google.com/uc?export=download^&id=FILE_ID
echo 4. Update installer with download URL
echo.

pause
