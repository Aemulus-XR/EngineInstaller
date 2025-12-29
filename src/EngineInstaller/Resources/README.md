# Resources Folder

This folder contains embedded resources for the installer.

## Required Files

### 7za.exe (Required)
The standalone 7-Zip command-line executable for extracting archives.

**Download:**
1. Go to https://www.7-zip.org/download.html
2. Download **7-Zip Extra** package (e.g., `7z2408-extra.7z`)
3. Extract the archive
4. Copy `7za.exe` to this folder (`src/EngineInstaller/Resources/7za.exe`)

**Version:** Latest stable (currently 24.08)
**Size:** ~1.5 MB
**License:** LGPL (compatible with distribution)

## Files in This Folder

- `7za.exe` - Standalone 7-Zip extractor (you need to download this)
- `Download-Archive.ps1` - PowerShell script to download engine archive from Dropbox
- `Extract-Archive.ps1` - PowerShell script to extract the downloaded archive

## Build Process

During the WiX build, these files are embedded into the MSI:
- `7za.exe` → Extracted to `%TEMP%` during installation
- PowerShell scripts → Executed via custom actions
- `DownloadConfig.json` → Read to get download URL
