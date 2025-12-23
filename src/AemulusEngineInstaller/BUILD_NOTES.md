# Production Build Notes

## Source Statistics
- **Total Files**: ~290,000 files
- **Source Location**: `UEOculusDrop/LocalBuilds/Engine/Windows/`
- **Estimated Build Time**: 5-15 minutes (depending on hardware)
- **Expected MSI Size**: 8-15 GB

## What to Expect During Build

### Phase 1: Heat Harvesting (Longest Phase)
WiX Heat will scan all 290,000+ files and generate component definitions.
- **Duration**: 2-10 minutes
- **What you'll see**: Multiple Heat.exe processes running
- **Output**: Four _*Components_dir.wxs files in obj/x64/Release/
- **Warnings**: Expect HEAT5149 (deprecation) and HEAT5151 (non-.NET assemblies) - these are normal

### Phase 2: WiX Compilation
WiX compiler processes the harvested files.
- **Duration**: 1-3 minutes
- **Memory usage**: Can reach 2-4 GB
- **What you'll see**: wix.exe processing

### Phase 3: Linking & CAB Creation
Creates the MSI and embeds all files in a cabinet file.
- **Duration**: 2-5 minutes
- **Disk I/O**: Heavy - reading all source files and compressing
- **Output**: AemulusEngineInstaller.msi in bin/x64/Release/

## Potential Issues & Solutions

### Issue: Path Too Long
**Symptom**: Error about paths exceeding 260 characters
**Solution**:
- Enable Windows Long Path support: `Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1`
- Or use shorter output paths

### Issue: Out of Memory
**Symptom**: Build crashes or system becomes unresponsive
**Solution**:
- Close other applications
- Increase virtual memory/page file
- Build on machine with more RAM

### Issue: File Locked
**Symptom**: "Cannot access file..." errors
**Solution**:
- Close Visual Studio, Unreal Editor, any file explorers in LocalBuilds
- Run build from fresh command prompt

### Issue: Very Slow Build
**Symptom**: Build takes over 20 minutes
**Solution**:
- Check antivirus isn't scanning build files
- Use SSD instead of HDD
- Disable real-time scanning temporarily

## Build Command

```batch
cd EngineInstaller\src\AemulusEngineInstaller
dotnet build -c Release
```

Or use the build script:
```batch
BuildInstaller.bat
```

## Output Location

```
EngineInstaller/src/AemulusEngineInstaller/bin/x64/Release/AemulusEngineInstaller.msi
```

## Testing the Installer

**IMPORTANT**: Test in a VM or on a non-development machine first!

1. Copy the MSI to test machine
2. Double-click to run
3. Follow installation wizard
4. Verify installation at: `C:\Program Files\Aemulus-XR\UE_5.6_OculusDrop\`
5. Test shortcuts work
6. Test UnrealEditor.exe launches
7. Test uninstall from Add/Remove Programs

## Success Criteria

- ✓ Build completes without errors
- ✓ MSI file is 8-15 GB
- ✓ Only warnings are HEAT5149, HEAT5151, and NU1903 (known issues)
- ✓ Installer runs without errors
- ✓ All files install correctly
- ✓ Shortcuts work
- ✓ Uninstall removes everything

Good luck! This is a big build. Be patient and monitor for errors.
