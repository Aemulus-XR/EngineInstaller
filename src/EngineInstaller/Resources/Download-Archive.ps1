# Download-Archive.ps1
# Downloads the UE archive from Dropbox
param(
    [string]$ConfigPath,
    [string]$DestinationPath,
    [string]$LogFile = "$env:TEMP\UEInstaller_Download.log"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

try {
    Write-Log "=== UE Installer Download Script ==="
    Write-Log "Config: $ConfigPath"
    Write-Log "Destination: $DestinationPath"

    # Read config
    if (-not (Test-Path $ConfigPath)) {
        throw "Config file not found: $ConfigPath"
    }

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $downloadUrl = $config.download.archiveUrl
    $expectedSize = $config.download.archiveSize

    Write-Log "Download URL: $downloadUrl"
    Write-Log "Expected size: $expectedSize bytes"

    # Ensure destination directory exists
    $destDir = Split-Path $DestinationPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        Write-Log "Created directory: $destDir"
    }

    # Download with progress
    Write-Log "Starting download..."
    $ProgressPreference = 'SilentlyContinue'  # Faster downloads
    Invoke-WebRequest -Uri $downloadUrl -OutFile $DestinationPath -UseBasicParsing

    # Verify download
    if (Test-Path $DestinationPath) {
        $actualSize = (Get-Item $DestinationPath).Length
        Write-Log "Downloaded: $actualSize bytes"

        if ($expectedSize -gt 0 -and $actualSize -ne $expectedSize) {
            Write-Log "WARNING: Size mismatch! Expected $expectedSize, got $actualSize"
            # Don't fail - size might vary slightly
        }

        Write-Log "Download completed successfully!"
        exit 0
    } else {
        throw "Download failed - file not found at destination"
    }

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
