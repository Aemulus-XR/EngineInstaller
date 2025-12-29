# Extract-Archive.ps1
# Extracts the 7z archive using 7za.exe
param(
    [string]$ArchivePath,
    [string]$DestinationPath,
    [string]$SevenZipPath,
    [string]$LogFile = "$env:TEMP\UEInstaller_Extract.log"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

try {
    Write-Log "=== UE Installer Extraction Script ==="
    Write-Log "Archive: $ArchivePath"
    Write-Log "Destination: $DestinationPath"
    Write-Log "7za.exe: $SevenZipPath"

    # Verify archive exists
    if (-not (Test-Path $ArchivePath)) {
        throw "Archive not found: $ArchivePath"
    }

    # Verify 7za.exe exists
    if (-not (Test-Path $SevenZipPath)) {
        throw "7za.exe not found: $SevenZipPath"
    }

    # Ensure destination exists
    if (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        Write-Log "Created directory: $DestinationPath"
    }

    Write-Log "Starting extraction..."
    $archiveSize = (Get-Item $ArchivePath).Length / 1GB
    Write-Log "Archive size: $([math]::Round($archiveSize, 2)) GB"

    # Extract with 7za
    # x = extract with full paths
    # -o = output directory (no space between -o and path)
    # -y = assume Yes on all queries
    $extractArgs = @(
        "x",
        "`"$ArchivePath`"",
        "-o`"$DestinationPath`"",
        "-y"
    )

    Write-Log "Running: $SevenZipPath $($extractArgs -join ' ')"

    $process = Start-Process -FilePath $SevenZipPath -ArgumentList $extractArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -eq 0) {
        Write-Log "Extraction completed successfully!"

        # Clean up archive
        Write-Log "Removing archive file..."
        Remove-Item $ArchivePath -Force
        Write-Log "Archive removed"

        exit 0
    } else {
        throw "7za.exe exited with code $($process.ExitCode)"
    }

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
