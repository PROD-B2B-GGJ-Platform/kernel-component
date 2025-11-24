# Kernel Component - Quick Start Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KERNEL COMPONENT - QUICK START" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure Maven is in PATH
$env:Path += ";C:\Users\dharm\.m2\wrapper\dists\apache-maven-3.9.6-bin\3311e1d4\apache-maven-3.9.6\bin"

# Navigate to component directory
Set-Location "C:\PROJECT_2025\GGJQ4_SPRINT01\B2B_PLATFORM\kernel-cluster\kernel-component"

Write-Host "📍 Current Directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

# Verify Maven
Write-Host "🔍 Verifying Maven..." -ForegroundColor Yellow
mvn -version
Write-Host ""

# Check if port is available
$port = 8083
$portInUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "⚠️  Port $port is already in use!" -ForegroundColor Red
    Write-Host "   Using port 8084 instead" -ForegroundColor Yellow
    $port = 8084
}

Write-Host "🚀 Starting Kernel Component on port $port..." -ForegroundColor Cyan
Write-Host "   Profile: dev (H2 Database)" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Start the application
& mvn spring-boot:run "-Dspring-boot.run.profiles=dev" "-Dspring-boot.run.jvmArguments=-Dserver.port=$port"

