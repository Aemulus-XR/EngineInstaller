# Watch the build log in real-time
# Usage: .\WatchBuild.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Watching build.log (Ctrl+C to exit)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "build.log") {
    Write-Host "Showing last 20 lines, then following..." -ForegroundColor Yellow
    Write-Host ""
    Get-Content build.log -Wait -Tail 20
} else {
    Write-Host "Waiting for build.log to be created..." -ForegroundColor Yellow
    # Wait for file to exist
    while (!(Test-Path "build.log")) {
        Start-Sleep -Milliseconds 500
    }
    Write-Host "build.log found! Starting watch..." -ForegroundColor Green
    Get-Content build.log -Wait -Tail 0
}
