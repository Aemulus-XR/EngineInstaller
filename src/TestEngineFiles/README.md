# Test Engine Files

This folder contains a minimal test structure for developing and testing the installer without requiring the full multi-GB Unreal Engine build.

## Purpose

During development, building the installer against the full engine build (LocalBuilds/Engine/Windows) is:
- **Slow**: Takes several minutes to harvest thousands of files
- **Resource-intensive**: Requires lots of disk I/O
- **Unnecessary**: For testing installer logic, we only need a minimal structure

## Structure

```
TestEngineFiles/
├── Engine/
│   ├── Binaries/
│   │   └── Win64/
│   │       └── UnrealEditor.exe (dummy file)
│   └── test_engine_file.txt
├── FeaturePacks/
│   └── test_featurepack.txt
├── Samples/
│   └── test_sample.txt
└── Templates/
    └── test_template.txt
```

## Switching Between Test and Production

### Development Mode (Current)
In `EngineInstaller.csproj`, line 9 points to TestEngineFiles:
```xml
<SourceDir Condition="'$(SourceDir)' == ''">$(MSBuildProjectDirectory)\..\TestEngineFiles</SourceDir>
```

### Production Mode
To build with the real engine files, edit `EngineInstaller.csproj`:
1. Comment out line 9 (TestEngineFiles)
2. Uncomment line 12 (production path)

Or use command line override:
```batch
dotnet build -c Release -p:SourceDir="E:\1\GitRepos\Aemulus-XR\UEOculusDrop\LocalBuilds\Engine\Windows"
```

## Adding Test Files

Feel free to add more test files here to verify:
- Directory structure creation
- File component generation
- Installer compression
- Shortcut creation
- Registry entries

Keep this folder lightweight for fast iteration!
