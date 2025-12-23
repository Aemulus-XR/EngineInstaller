# Hybrid Installer Architecture

## Overview
Instead of packaging 290,000 files directly into an MSI (which is taking 30+ minutes to build), we'll use a **two-part approach**:

1. **Small WiX Installer** (~5-20MB) - The "bootstrapper"
2. **7-Zip Archive** (~8-15GB) - Hosted on Google Drive

## User Experience Flow

```
1. User downloads: AemulusXR-UE-5.6-Installer.msi (small, ~10MB)
2. User runs installer
3. Installer shows:
   - Welcome screen
   - Choose installation directory (with default: C:\UE_5.6_OculusDrop)
   - Progress: "Downloading engine files from Google Drive..."
   - Progress: "Extracting files..."
   - Progress: "Creating shortcuts..."
   - Finish: "Launch Unreal Editor" checkbox
4. Desktop & Start Menu shortcuts created
5. Done!
```

## Technical Architecture

### Part 1: WiX Installer (This Project)
**Contains:**
- Installation wizard UI
- Embedded 7za.exe (~1.5MB standalone) - since 7-Zip is NOT pre-installed on Windows
- Custom actions to:
  - Download 7z archive from Dropbox
  - Extract using embedded 7za.exe
  - Create shortcuts
  - Register installation path
  - Handle cleanup on uninstall

**Doesn't contain:**
- The actual engine files (those are in the 7z archive)

**Note on 7-Zip:**
- 7-Zip is NOT pre-installed on Windows 10/11
- We embed 7za.exe (standalone console version) in the installer
- Alternative: Use .NET compression libraries, but 7za.exe is simpler and proven

### Part 2: 7-Zip Archive
**Created separately:**
- Clean the build folder (remove Intermediate, DerivedDataCache)
- Create: `UE_5.6_OculusDrop.7z` with solid compression
- Upload to Google Drive
- Get shareable direct download link

## Benefits

✅ **Fast installer builds**: 30 seconds instead of 30+ minutes
✅ **Handles long paths**: 7-Zip supports long paths better than ZIP
✅ **Reliable downloads**: Can retry if download fails
✅ **Smaller initial download**: User gets instant feedback
✅ **Easy updates**: Just update the 7z file and version number
✅ **Professional UX**: Looks like a real installer, not "extract this ZIP"
✅ **No Google Drive limits**: Direct download links work for team members

## Implementation Plan

### Phase 1: Cleanup & Archive Creation
1. Script to clean LocalBuilds folder (remove temp files)
2. Script to create 7z archive
3. Upload to Google Drive
4. Get direct download link

### Phase 2: Installer Redesign
1. Remove Heat harvesting (no longer packaging files)
2. Add embedded 7z.exe (or use WiX's DTF library)
3. Add custom action: Download from URL
4. Add custom action: Extract 7z
5. Add progress UI during download/extract
6. Keep shortcut creation

### Phase 3: Testing & Distribution
1. Test on clean VM
2. Document for team
3. Create update process

## File Structure

```
EngineInstaller/
├── src/
│   ├── AemulusEngineInstaller/      # WiX bootstrapper
│   │   ├── Package.wxs               # Installer definition
│   │   ├── CustomActions/            # Download & extract logic
│   │   ├── Resources/                # Embedded 7z.exe, icons
│   │   └── AemulusEngineInstaller.csproj
│   └── ArchiveBuilder/               # Scripts to create & upload 7z
│       ├── CleanBuild.bat
│       ├── Create7z.bat
│       └── UploadToGoogleDrive.ps1 (optional)
```

## Google Drive Integration

**Option A: Manual**
1. Create 7z file
2. Upload to Google Drive
3. Share with "Anyone with link"
4. Convert to direct download link
5. Hardcode URL in installer (or use config file)

**Option B: Automated** (future enhancement)
1. Use Google Drive API
2. Auto-upload on build
3. Auto-update installer with new URL

## Next Steps

Would you like me to:
1. **Cancel the current build** (it's still running but slow)
2. **Create cleanup script** to remove Intermediate/DerivedDataCache
3. **Create 7z archive script** with optimal compression
4. **Redesign the installer** as a lightweight bootstrapper
5. **Test the full flow**

This approach will be MUCH faster to build and distribute!
