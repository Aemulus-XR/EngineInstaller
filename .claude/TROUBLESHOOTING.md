# Troubleshooting Guide - EngineInstaller

## WiX v4 Custom Actions

### Issue: Parameters with spaces break in deferred custom actions
**Symptom**: Install folder path like `C:\Program Files\...` gets split at the space.

**Example Error**:
```
Install folder: 'C:\Program Files\Aemulus-XR\UE_5.6_OculusDrop" -MSIPath C:\Program'
MSI path: 'Files\Aemulus-XR\UE_5.6_OculusDrop\.installer"'
```

**Root Cause**: Spaces in path being interpreted as parameter separators.

**Solution**: Use pipe-delimited parameters
```xml
<!-- In Package.wxs -->
<CustomAction
  Id="SetRunInstallerData"
  Property="RunInstaller"
  Value="&quot;[InstallerResourcesFolder]|[INSTALLFOLDER]&quot;"
  Execute="immediate" />
```

```batch
REM In batch file
set "PARAMS=%~1"
for /f "tokens=1,2 delims=|" %%a in ("%PARAMS%") do (
    set "RESOURCES_FOLDER=%%a"
    set "INSTALL_FOLDER=%%b"
)
```

### Issue: Properties don't resolve in deferred custom actions
**Symptom**: Custom action executes but parameters are empty or unresolved.

**Root Cause**: WiX v4 deferred actions run in a different context and can't access installer properties directly.

**Solution**: Two-step custom action pattern
1. Immediate action: Resolve properties and set a custom property
2. Deferred action: Reference the custom property + specify Directory attribute

```xml
<!-- Immediate: Resolve properties -->
<CustomAction
  Id="SetRunInstallerData"
  Property="RunInstaller"
  Value="&quot;[InstallerResourcesFolder]|[INSTALLFOLDER]&quot;"
  Execute="immediate" />

<!-- Deferred: Execute with resolved data -->
<CustomAction
  Id="RunInstaller"
  Directory="InstallerResourcesFolder"
  ExeCommand='cmd.exe /c "RunInstall.bat [RunInstaller]"'
  Execute="deferred"
  Impersonate="yes"
  Return="check" />

<!-- Sequence: Immediate before deferred -->
<InstallExecuteSequence>
  <Custom Action="SetRunInstallerData" After="InstallFiles" Condition="NOT Installed" />
  <Custom Action="RunInstaller" After="SetRunInstallerData" Condition="NOT Installed" />
</InstallExecuteSequence>
```

### Issue: WIX0037 - ExeCommand requires BinaryRef, Directory, FileRef, or Property
**Symptom**: Build fails with error about missing required attribute.

**Root Cause**: ExeCommand custom actions must specify where to execute from.

**Solution**: Add `Directory` attribute pointing to a valid directory reference:
```xml
<CustomAction
  Id="RunInstaller"
  Directory="InstallerResourcesFolder"  <!-- Add this -->
  ExeCommand='cmd.exe /c "RunInstall.bat"'
  Execute="deferred" />
```

### Issue: Batch file never executes (MSI returns success but no output)
**Symptom**: MSI log shows custom action succeeded but no batch log created.

**Root Cause**: File path references like `[#FileId]` or `[CustomActionData]` don't work in WiX v4 ExeCommand.

**Solution**: Use the two-step pattern above with Directory attribute.

## PowerShell Script Issues

### Issue: "Cannot bind argument to parameter 'Path' because it is null"
**Symptom**: Script fails during extraction phase with null path error.

**Example**:
```
ERROR: Cannot bind argument to parameter 'Path' because it is null.
Stack trace: at <ScriptBlock>, Install-Engine.ps1: line 79
```

**Root Cause**: Undefined variable used instead of script parameter.

**Solution**: Check variable names match parameters:
```powershell
# WRONG
$sevenZipPath = Join-Path $msiDir "7za.exe"  # $msiDir is undefined

# CORRECT
$sevenZipPath = Join-Path $MSIPath "7za.exe"  # $MSIPath is the parameter
```

### Issue: PowerShell parameters with special characters break
**Symptom**: Parameters with quotes, spaces, or special characters don't pass correctly to PowerShell.

**Solution**: Use environment variables instead of command-line parameters:
```batch
REM Set environment variables
set "PS_INSTALL_FOLDER=!INSTALL_FOLDER!"
set "PS_MSI_PATH=!RESOURCES_FOLDER!"

REM PowerShell reads from environment
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "& '%PS_MSI_PATH%Install-Engine.ps1' -InstallFolder $env:PS_INSTALL_FOLDER -MSIPath $env:PS_MSI_PATH"
```

## Build Issues

### Issue: Windows Installer service failed (1631)
**Symptom**: Build fails with WIX0001 error code 1631.

**Root Cause**: File locks from previous installer or terminal windows.

**Solution**: Close any open installer windows, command prompts, or PowerShell windows that may be holding locks.

### Issue: Logs show UTF-16 encoding (��2 0 2 5 - 1 2...)
**Symptom**: Log files appear garbled with null bytes between characters.

**Root Cause**: PowerShell `Out-File` defaults to UTF-16 on Windows.

**Not Actually a Problem**: This is normal PowerShell behavior. The logs are readable in Windows tools. To force UTF-8:
```powershell
"$timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
```

## Installation Issues

### Issue: Temp files not deleted after install failure
**Symptom**: 19GB archive remains in `%TEMP%` after installation fails.

**Root Cause**: Error handling doesn't clean up downloaded files.

**Solution** (TODO): Add cleanup in error handler:
```powershell
} catch {
    Write-Log "ERROR: $($_.Exception.Message)"

    # Cleanup temp files
    if (Test-Path $archivePath) {
        Write-Log "Removing temporary archive..."
        Remove-Item $archivePath -Force -ErrorAction SilentlyContinue
    }

    exit 1
}
```

### Issue: Download fails on slow connections
**Symptom**: Download times out or shows incomplete.

**Solution** (TODO): Add timeout configuration and retry logic:
```powershell
$retries = 3
$timeout = 1800  # 30 minutes

for ($i = 0; $i -lt $retries; $i++) {
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing -TimeoutSec $timeout
        break
    } catch {
        if ($i -eq $retries - 1) { throw }
        Write-Log "Download attempt $($i + 1) failed, retrying..."
    }
}
```

## File Paths and Locations

### Log File Locations (for debugging)
- **PowerShell log**: `E:\1\GitRepos\Aemulus-XR\EngineInstaller\UEInstaller.log`
- **Batch log**: `E:\1\GitRepos\Aemulus-XR\EngineInstaller\UEInstaller_Batch.log`
- **Download location**: `%TEMP%\UE_5.6_OculusDrop.7z`
- **MSI build log**: `E:\1\GitRepos\Aemulus-XR\EngineInstaller\src\EngineInstaller\build.log`

### Log File Encoding Notes
The PowerShell logs are UTF-16 encoded (Windows default), which appears as:
```
��2 0 2 5 - 1 2 - 2 9   1 1 : 0 3 : 0 2   -   = = =   U E   I n s t a l l e r...
```

This is normal and the files are readable in Windows Notepad, VS Code, and other Windows tools.

## Performance Optimization

### 7-Zip Extraction Speed
**Current Implementation** (basic):
```powershell
$extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y")
```

**Optimization Options** (to implement after basic functionality works):

1. **Multi-threading** - Use `-mmt` flag to enable parallel decompression:
   ```powershell
   $extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y", "-mmt=on")
   # Or specify core count: "-mmt=8"
   ```

2. **Memory allocation** - Increase dictionary size for faster decompression:
   ```powershell
   $extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y", "-mmt=on", "-mx=0")
   # -mx=0 means copy mode (no compression), fastest extraction
   ```

3. **Progress reporting** - Add `-bsp1` for progress updates (redirect to log):
   ```powershell
   $extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y", "-mmt=on", "-bsp1")
   # Requires capturing stdout to show progress to user
   ```

4. **Combination** for best performance:
   ```powershell
   $coreCount = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
   $extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y", "-mmt=$coreCount", "-bsp1")
   ```

**Expected Improvements**:
- Multi-threading: 2-4x faster on modern CPUs (8+ cores)
- Current: ~10-15 minutes estimated
- Optimized: ~3-5 minutes estimated

**TODO**: Implement after verifying basic extraction works.

## Critical Engine Folders

### Engine/Intermediate/Build/BuildRules
**MUST BE INCLUDED** in the archive!

**Error if missing**:
```
Precompiled rules assembly 'D:\bin\UE_5.6_OculusDrop\Engine\Intermediate\Build\BuildRules\UE5Rules.dll' does not exist.
```

**What it contains**:
- `UE5Rules.dll` - Precompiled UnrealBuildTool rules
- Required for generating project files and building
- Without it, users cannot open .uproject files or generate VS Code projects

**Archive creation**:
The `CreateEngineArchive.bat` script now:
1. Deletes `Engine/Intermediate/*` (temp files)
2. **EXCEPT** `Engine/Intermediate/Build/BuildRules/` (keeps this)
3. Saves ~5-10GB by removing temp files while preserving critical build files

**Verification**:
After creating archive, check that BuildRules is included:
```cmd
7z l Output\UE_5.6_OculusDrop.7z | findstr /i "BuildRules"
```

Should show files like:
```
Engine\Intermediate\Build\BuildRules\UE5Rules.dll
Engine\Intermediate\Build\BuildRules\UE5Rules.pdb
```

## Registry Research

### Finding Unreal Engine Registry Keys
To implement registry integration, we need to research how Epic Games Launcher and UE handle registry entries.

**Steps to Research**:
1. **Export Epic's registry keys** (if UE is installed via Epic Games Launcher):
   ```cmd
   reg export "HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames" epic_hklm.reg
   reg export "HKEY_CURRENT_USER\SOFTWARE\EpicGames" epic_hkcu.reg
   ```

2. **Search for engine install paths**:
   ```cmd
   reg query "HKLM\SOFTWARE\EpicGames" /s | findstr /i "engine install path"
   reg query "HKCU\SOFTWARE\EpicGames" /s | findstr /i "engine install path"
   ```

3. **Check UnrealVersionSelector**:
   - Location: Usually in `C:\Program Files (x86)\Epic Games\Launcher\Engine\Binaries\Win64\`
   - This tool registers .uproject associations
   - Run with `/help` to see options

4. **Monitor registry changes**:
   - Use Process Monitor (procmon.exe) from Sysinternals
   - Filter for UnrealEditor.exe and registry operations
   - Run the engine and watch what registry keys it accesses

### Common Registry Locations (to verify)
```
HKLM\SOFTWARE\EpicGames\Unreal Engine\<Version>
  - InstallLocation (or similar)

HKCU\SOFTWARE\Epic Games\Unreal Engine\Builds
  - Custom engine builds registered here
  - Key format: {GUID} -> "C:\Path\To\Engine"

HKLM\SOFTWARE\Classes\.uproject
  - File association for .uproject files

HKLM\SOFTWARE\Classes\Unreal.ProjectFile
  - Handler for .uproject files
```

### Implementation Notes
Once we identify the correct keys:
1. Add WiX `RegistrySearch` to read Epic's default path
2. Add PowerShell code to write our engine registration
3. Add WiX `RegistryValue` elements for uninstall cleanup

## Testing Tips

### Quick Build Cycle
1. Edit scripts in `src/EngineInstaller/Resources/`
2. Run: `dotnet build -c Release` in `src/EngineInstaller/`
3. Install MSI from `bin\x64\Release\EngineInstaller.msi`
4. Check logs in `E:\1\GitRepos\Aemulus-XR\EngineInstaller\`

### Testing Without Full Download
To test extraction without re-downloading:
1. Keep the 19GB file in `%TEMP%\UE_5.6_OculusDrop.7z`
2. Comment out download section in `Install-Engine.ps1`
3. Test extraction logic only

### Monitoring Extraction Progress
While extraction is running:
1. Open Task Manager → Details tab
2. Find `7za.exe` process
3. Watch CPU usage (should be high with `-mmt=on`)
4. Watch disk I/O (Performance tab)
5. Check install folder size growth: `Get-ChildItem "D:\bin\UE_5.6_OculusDrop" -Recurse | Measure-Object -Property Length -Sum`

### Clean Test Environment
Before testing installer:
1. Delete previous installation folder
2. Delete `%TEMP%\UE_5.6_OculusDrop.7z`
3. Clear log files in EngineInstaller directory
4. Close any open terminals or installer windows
