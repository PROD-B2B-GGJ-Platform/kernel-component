# ========================================================================
# Kernel Component - Installation Script (Windows)
# ========================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  KERNEL COMPONENT INSTALLATION" -ForegroundColor Cyan
Write-Host "  Version: 10.0.0.1" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: Java 17+ is required" -ForegroundColor Red
    exit 1
}

try {
    $mvnVersion = mvn -v 2>&1 | Select-String "Apache Maven"
    Write-Host "✓ Maven found: $mvnVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Error: Maven 3.9+ is required" -ForegroundColor Red
    exit 1
}

# Step 2: Build application
Write-Host "[2/6] Building application..." -ForegroundColor Yellow
mvn clean package -DskipTests
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Build completed" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}

# Step 3: Create directories
Write-Host "[3/6] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path logs | Out-Null
New-Item -ItemType Directory -Force -Path config | Out-Null
Write-Host "✓ Directories created" -ForegroundColor Green

# Step 4: Copy configuration files
Write-Host "[4/6] Copying configuration..." -ForegroundColor Yellow
Copy-Item src\main\resources\application.yml config\
Copy-Item src\main\resources\application-dev.yml config\
Write-Host "✓ Configuration copied" -ForegroundColor Green

# Step 5: Setup database (optional)
Write-Host "[5/6] Database setup..." -ForegroundColor Yellow
$response = Read-Host "Do you want to run Flyway migrations now? (y/n)"
if ($response -eq 'y') {
    mvn flyway:migrate
    Write-Host "✓ Database migrations completed" -ForegroundColor Green
} else {
    Write-Host "⚠ Skipped database migrations" -ForegroundColor Yellow
}

# Step 6: Final message
Write-Host "[6/6] Installation complete!" -ForegroundColor Yellow
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION SUCCESSFUL!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the application:"
Write-Host "  .\scripts\start.ps1"
Write-Host ""
Write-Host "API will be available at:"
Write-Host "  http://localhost:8083/api/v1/kernel"
Write-Host ""

