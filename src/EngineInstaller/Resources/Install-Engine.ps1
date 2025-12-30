# Install-Engine.ps1
# Main installation script - downloads and extracts UE engine
param(
    [string]$InstallFolder,
    [string]$MSIPath
)

$ErrorActionPreference = "Stop"
$LogFile = "E:\1\GitRepos\Aemulus-XR\EngineInstaller\UEInstaller.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

# Clear previous log
if (Test-Path $LogFile) {
    Remove-Item $LogFile -Force
}

try {
    Write-Log "=== UE Installer Script Started ==="
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Log "Install folder: '$InstallFolder'"
    Write-Log "MSI path: '$MSIPath'"
    Write-Log "Working directory: $PWD"

    # Debug: List what's in MSIPath
    Write-Log "Checking MSI path contents..."
    if (Test-Path $MSIPath) {
        Write-Log "MSI path exists: $MSIPath"
        $items = Get-ChildItem -Path $MSIPath -ErrorAction SilentlyContinue
        Write-Log "Items in MSI path: $($items.Count)"
        foreach ($item in $items) {
            Write-Log "  - $($item.Name)"
        }
    } else {
        Write-Log "WARNING: MSI path does not exist: $MSIPath"
    }

    # Look for DownloadConfig.json in the MSI directory
    $configPath = Join-Path $MSIPath "DownloadConfig.json"
    Write-Log "Looking for config at: $configPath"

    if (-not (Test-Path $configPath)) {
        # Try without quotes in case they're being passed literally
        $configPath = "$MSIPath\DownloadConfig.json"
        Write-Log "Trying alternate path: $configPath"

        if (-not (Test-Path $configPath)) {
            throw "Config file not found at: $configPath`nMSI path was: $MSIPath"
        }
    }

    Write-Log "Found config: $configPath"

    # Read download configuration
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $downloadUrl = $config.download.archiveUrl
    $archivePath = "$env:TEMP\UE_5.6_OculusDrop.7z"

    Write-Log "Download URL: $downloadUrl"

    # Download archive
    Write-Log "Downloading engine archive (this may take 10-30 minutes)..."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing

    if (-not (Test-Path $archivePath)) {
        throw "Download failed"
    }

    $sizeGB = [math]::Round((Get-Item $archivePath).Length / 1GB, 2)
    Write-Log "Downloaded: $sizeGB GB"

    # Extract using 7za.exe from MSI directory
    $sevenZipPath = Join-Path $MSIPath "7za.exe"
    if (-not (Test-Path $sevenZipPath)) {
        throw "7za.exe not found: $sevenZipPath"
    }

    Write-Log "Extracting archive to: $InstallFolder"
    Write-Log "This will take 3-5 minutes with multi-threading..."

    # Get CPU core count for optimal multi-threading
    $coreCount = (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
    Write-Log "Using $coreCount CPU threads for extraction"

    # Enable multi-threading and progress reporting for faster extraction
    $extractArgs = @("x", "`"$archivePath`"", "-o`"$InstallFolder`"", "-y", "-mmt=$coreCount", "-bsp1")
    $process = Start-Process -FilePath $sevenZipPath -ArgumentList $extractArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        throw "Extraction failed with code $($process.ExitCode)"
    }

    Write-Log "Extraction complete!"

    # Cleanup
    Write-Log "Removing temporary archive..."
    Remove-Item $archivePath -Force -ErrorAction SilentlyContinue

    Write-Log "=== Installation Complete! ==="
    exit 0

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"

    # Show error to user
    [System.Windows.Forms.MessageBox]::Show(
        "Installation failed: $($_.Exception.Message)`n`nCheck log: $LogFile",
        "Installation Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null

    exit 1
}
