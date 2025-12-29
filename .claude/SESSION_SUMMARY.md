# Session Summary - EngineInstaller Project

## What We Accomplished ✅

### 1. Project Setup & Initial Approach
- Created WiX v4 installer project from scratch
- Configured Heat harvesting for automatic file discovery
- Built test installer successfully (324KB with test files)
- **Problem discovered**: Packaging 290,226 files directly in MSI takes 30+ minutes and creates massive installer

### 2. Pivoted to Hybrid Approach
- **Key insight**: Team of 2-3 needs reliable distribution, not traditional installer
- **Decision**: Two-part system - lightweight installer + cloud-hosted archive
- **Advantages**:
  - Fast installer builds (seconds vs hours)
  - Reliable downloads from Dropbox
  - Handles long paths better
  - Professional UX for semi-technical users
  - Easy updates (just replace archive)

### 3. Archive Builder Created
- Script: `src/ArchiveBuilder/CreateEngineArchive.bat`
- Cleans unnecessary files (Intermediate, DerivedDataCache)
- Creates optimized 7z archive
- **Results**:
  - Source: ~30-40 GB (290,226 files)
  - After cleanup: ~25-30 GB
  - Compressed: 19 GB 7z archive
  - Compression: ~2 hours
  - Extraction: ~10 minutes
  - ✅ Tested and working!

### 4. Repository Cleanup
- Created proper .gitignore
- Removed build artifacts (bin, obj)
- Organized documentation
- Files created:
  - `.claude/HYBRID_APPROACH.md` - Architecture design
  - `.claude/Instructions.md` - Project knowledge base
  - `QUICKSTART.md` - User guide
  - `src/ArchiveBuilder/README.md` - Builder docs
  - Build monitoring scripts (CheckBuildStatus.bat, WatchBuild.ps1)

## Current Status

✅ **Phase 1 Complete**: Archive Creation
- Archive built and tested
- Uploaded to Dropbox (19GB)
- Unreal Engine runs from extracted files

✅ **Phase 2 Nearly Complete**: Installer Development
- Lightweight WiX installer built (724KB)
- Downloads from Dropbox successfully
- **Current issue**: Extraction error fixed (line 79: changed `$msiDir` to `$MSIPath`)
- Testing extraction phase now

## Distribution Plan

**Chosen Platform**: Dropbox (2TB paid account)
- No download quotas (unlike Google Drive)
- Simple direct download URLs (`?dl=1`)
- Fast, reliable for team use
- Perfect for 2-3 person team + contractors

**Update Frequency**: Every 2-3 weeks
1. Run `GenerateInstallBuild.bat` in UEOculusDrop
2. Run `CreateEngineArchive.bat` (~2 hours)
3. Replace archive on Dropbox
4. Notify team

## Key Technical Solutions

### WiX v4 Deferred Custom Action with Parameters
**Problem**: Deferred custom actions can't access properties like `[INSTALLFOLDER]` directly.

**Solution**: Two-step custom action pattern:
```xml
<!-- Step 1: Immediate action sets property with resolved values -->
<CustomAction
  Id="SetRunInstallerData"
  Property="RunInstaller"
  Value="&quot;[InstallerResourcesFolder]|[INSTALLFOLDER]&quot;"
  Execute="immediate" />

<!-- Step 2: Deferred action uses the property + Directory attribute -->
<CustomAction
  Id="RunInstaller"
  Directory="InstallerResourcesFolder"
  ExeCommand='cmd.exe /c "RunInstall.bat [RunInstaller]"'
  Execute="deferred"
  Impersonate="yes"
  Return="check" />

<InstallExecuteSequence>
  <Custom Action="SetRunInstallerData" After="InstallFiles" />
  <Custom Action="RunInstaller" After="SetRunInstallerData" />
</InstallExecuteSequence>
```

### Pipe-Delimited Parameters
**Problem**: Spaces in "Program Files" break parameter parsing.

**Solution**: Use pipe delimiter (`|`) for parameter passing:
- WiX sets: `"D:\path\to\resources|C:\Program Files\Install\Path"`
- Batch parses: `for /f "tokens=1,2 delims=|" %%a in ("%PARAMS%")`

### Environment Variable Approach
**Problem**: PowerShell parameters with spaces and special characters.

**Solution**: Set environment variables in batch, read in PowerShell:
```batch
set "PS_INSTALL_FOLDER=!INSTALL_FOLDER!"
set "PS_MSI_PATH=!RESOURCES_FOLDER!"
powershell.exe ... -Command "& 'script.ps1' -InstallFolder $env:PS_INSTALL_FOLDER -MSIPath $env:PS_MSI_PATH"
```

## Next Steps

### Current (Testing Phase)
1. ✅ Fixed undefined variable error
2. 🔄 Test extraction with corrected script
3. Verify complete installation flow
4. Add temp file cleanup on failure
5. Add disk space checking

### Future Enhancements
1. Add disk space check before download (~19GB in TEMP + install space)
2. Add UI option to customize temporary download location
3. Improve progress UI during download/extraction
4. Add retry logic for failed downloads
5. Distribute to team

## Key Files

```
EngineInstaller/
├── .claude/
│   ├── HYBRID_APPROACH.md        # Architecture design
│   ├── Instructions.md            # Project knowledge base
│   └── SESSION_SUMMARY.md         # This file
├── src/
│   ├── ArchiveBuilder/
│   │   ├── CreateEngineArchive.bat  # Archive creation script ✅
│   │   ├── Output/
│   │   │   └── UE_5.6_OculusDrop.7z # 19GB archive ✅
│   │   └── README.md
│   └── EngineInstaller/
│       ├── Package.wxs            # WiX installer (needs redesign)
│       └── BuildInstaller.bat
├── QUICKSTART.md                  # User guide
└── README.md                      # Project overview
```

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| 7-Zip over ZIP | Better compression, handles long paths |
| Dropbox over Google Drive | No quotas, simpler URLs, paid account available |
| Hybrid vs monolithic MSI | 290K files too slow, 2hr build vs seconds |
| Clean Intermediate folders | Auto-regenerated, saves ~5-10 GB |
| WiX v4 over v3 | Modern, .NET-based, better tooling |

## Issues Resolved

### Archive & Distribution
1. ✅ Path length issues in batch scripts (relative path counting)
2. ✅ WiX build taking 30+ minutes (switched to hybrid)
3. ✅ Long filename issues with ZIP (using 7z instead)
4. ✅ Google Drive quota concerns (using Dropbox)
5. ✅ Repository clutter (cleaned with .gitignore)

### Phase 2 Installer Development (Current Session)
6. ✅ Parameter passing with spaces in paths (solved with pipe delimiter)
7. ✅ WiX v4 deferred custom action property resolution (immediate action + Directory attribute)
8. ✅ Batch file not executing (ExeCommand requires Directory, BinaryRef, FileRef, or Property)
9. ✅ Download functionality (PowerShell Invoke-WebRequest)
10. ✅ Undefined variable error in Install-Engine.ps1 (line 79: `$msiDir` → `$MSIPath`)

## Metrics

- **Files in engine build**: 290,226
- **Original size**: ~30-40 GB
- **Cleaned size**: ~25-30 GB
- **Archive size**: 19 GB (48% compression ratio)
- **Compression time**: ~2 hours (one-time cost)
- **Extraction time**: ~10 minutes (user experience)
- **Team size**: 2-3 initial, expanding to contractors
- **Update frequency**: Every 2-3 weeks

## Success Criteria Met

✅ Archive creation automated
✅ Files compressed reliably
✅ Long paths handled
✅ Extract tested and working
✅ Unreal Engine runs from extracted files
✅ Distribution platform selected (Dropbox)
✅ Documentation complete

## Ready for Next Phase

The foundation is solid. When ready to continue:
1. Upload archive to Dropbox
2. Get direct download URL
3. Build lightweight installer with download/extract
4. Test with team members
5. Deploy!
