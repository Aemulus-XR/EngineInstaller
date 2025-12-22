# Aemulus-XR Engine Installer - Source

This directory contains the WiX-based installer project for the Aemulus-XR Unreal Engine 5.6 OculusDrop edition.

## Prerequisites

- .NET SDK 9.0 or later
- WiX Toolset v4 (installed as .NET global tool: `dotnet tool install --global wix`)
- Completed engine build in `UEOculusDrop/LocalBuilds/Engine/Windows/`

## Project Structure

```
src/
├── AemulusEngineInstaller/          # WiX installer project
│   ├── Package.wxs                   # Main WiX source file
│   ├── AemulusEngineInstaller.csproj # MSBuild project file
│   └── BuildInstaller.bat            # Build script
└── README.md                         # This file
```

## Building the Installer

### Step 1: Build the Engine

First, ensure you have a completed engine build:

```batch
cd UEOculusDrop
GenerateInstallBuild.bat
```

This will generate the engine files in `UEOculusDrop/LocalBuilds/Engine/Windows/`

### Step 2: Build the Installer

Run the build script:

```batch
cd EngineInstaller\src\AemulusEngineInstaller
BuildInstaller.bat
```

Or build manually:

```batch
cd EngineInstaller\src\AemulusEngineInstaller
dotnet build -c Release
```

### Output

The installer MSI will be created at:
```
src/AemulusEngineInstaller/bin/Release/net9.0/en-US/AemulusEngineInstaller.msi
```

## Installer Features

- **Installation Directory**: Default to `C:\Program Files\Aemulus-XR\UE_5.6_OculusDrop`
- **Custom Path Support**: Users can choose installation location
- **Desktop Shortcut**: Creates shortcut to UnrealEditor.exe
- **Start Menu**: Adds "Aemulus-XR Unreal Engine 5.6" folder with shortcut
- **Upgrade Support**: Upgrades existing installations in place
- **Clean Uninstall**: Removes all files, shortcuts, and registry entries

## Technical Details

- **WiX Version**: 4.0.1
- **Platform**: x64 only
- **Installer Type**: MSI (Windows Installer)
- **Compression**: Cabinet file compression enabled
- **UI**: Standard WiX InstallDir UI with custom branding

## Customization

To modify the installer:

1. Edit `Package.wxs` for installer logic and structure
2. Update version numbers in both `Package.wxs` and `.csproj`
3. Modify shortcuts, registry entries, or features as needed
4. Rebuild using `BuildInstaller.bat`

## Version Management

When updating to a new engine version:

1. Update the `Version` attribute in `Package.wxs` (line 9)
2. Update folder names if needed (e.g., `UE_5.7_OculusDrop`)
3. Update product name and descriptions
4. Keep the same `UpgradeCode` GUID for upgrade-in-place support

## Troubleshooting

**Build fails with "Source directory not found"**
- Ensure you've run `GenerateInstallBuild.bat` in UEOculusDrop first
- Check that `LocalBuilds/Engine/Windows/` exists and contains files

**WiX tool not found**
- Install WiX globally: `dotnet tool install --global wix`
- Verify installation: `wix --version`

**Permission errors during build**
- Run command prompt as Administrator
- Check antivirus isn't blocking the build

## License

See [LICENSE.md](../../LICENSE.md) in the repository root.
