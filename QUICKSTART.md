# Quick Start Guide

## Creating the Distribution Archive

### Step 1: Create the 7z Archive

```batch
cd src\ArchiveBuilder
CreateEngineArchive.bat
```

This will:
- ✅ Clean temporary files from the engine build
- ✅ Create `UE_5.6_OculusDrop.7z` (~19 GB compressed)
- ⏱️ Takes ~2 hours to compress (extraction: ~10 minutes)

**Output**: `src/ArchiveBuilder/Output/UE_5.6_OculusDrop.7z`

### Step 2: Upload to Dropbox

1. Upload `UE_5.6_OculusDrop.7z` to Dropbox (via desktop app or web)
2. Right-click file → Share → Create link
3. Copy the share URL
4. Change `?dl=0` to `?dl=1` for direct download:
   ```
   https://www.dropbox.com/s/YOUR_ID/UE_5.6_OculusDrop.7z?dl=1
   ```

### Step 3: Test the Archive

Before building the installer, test extraction:
```batch
7z x UE_5.6_OculusDrop.7z -oC:\TestExtract
```

Verify:
- All files extracted
- No path length errors
- UnrealEditor.exe runs

## What Gets Cleaned

The archive excludes these auto-generated folders:
- `Engine/Intermediate/` - Build intermediates
- `Engine/DerivedDataCache/` - Shader cache
- `Engine/Saved/Logs/` - Log files
- `Engine/Saved/Crashes/` - Crash dumps
- Template and Sample intermediates

These are regenerated on first run of UE.

## File Size Expectations (Actual)

- **Before cleanup**: ~30-40 GB
- **After cleanup**: ~25-30 GB
- **7z archive**: ~19 GB (compressed, actual result)
- **Dropbox**: 2TB available (19 GB is 1% of quota)
- **Compression time**: ~2 hours
- **Extraction time**: ~10 minutes

## Next Phase: Hybrid Installer

See [HYBRID_APPROACH.md](.claude/HYBRID_APPROACH.md) for the installer redesign that will:
- Download this archive from Google Drive
- Extract with long path support
- Create shortcuts
- Provide professional UX

## Troubleshooting

**"7z not found"**
- Install 7-Zip: https://www.7-zip.org/
- Add to PATH or run from `C:\Program Files\7-Zip\`

**Archive too large**
- Check cleanup ran correctly
- Manually verify Intermediate folders are gone
- Consider excluding Samples if not needed

**Upload fails**
- Use Google Drive Desktop app for large files
- Or split into chunks (advanced)

## Distribution Frequency

Updates expected every 2-3 weeks:
1. Run `GenerateInstallBuild.bat` in UEOculusDrop
2. Run `CreateEngineArchive.bat`
3. Replace archive on Google Drive (keep same filename for consistent URLs)
4. Notify team of update
