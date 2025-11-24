# ========================================================================
# Kernel Component - Environment Setup Script (Windows)
# Run as Administrator
# ========================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  KERNEL COMPONENT - ENVIRONMENT SETUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   Some settings may not be saved permanently" -ForegroundColor Yellow
    Write-Host ""
}

# Step 1: Detect Java Installation
Write-Host "[1/4] Detecting Java installation..." -ForegroundColor Yellow

$javaLocations = @(
    "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot",
    "C:\Program Files\Java\jdk-17",
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot",
    "C:\Program Files\Java\jdk-17.0.17"
)

$javaHome = $null
foreach ($location in $javaLocations) {
    if (Test-Path $location) {
        $javaHome = $location
        break
    }
}

if ($javaHome) {
    Write-Host "✓ Java found at: $javaHome" -ForegroundColor Green
    
    if ($isAdmin) {
        [System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaHome, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "✓ JAVA_HOME set permanently" -ForegroundColor Green
    } else {
        $env:JAVA_HOME = $javaHome
        Write-Host "✓ JAVA_HOME set for current session" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Java 17 not found" -ForegroundColor Red
    Write-Host "  Please install Java 17 from:" -ForegroundColor Yellow
    Write-Host "  https://learn.microsoft.com/en-us/java/openjdk/download" -ForegroundColor Yellow
    exit 1
}

# Step 2: Detect Maven Installation
Write-Host "`n[2/4] Detecting Maven installation..." -ForegroundColor Yellow

$mavenLocations = @(
    "C:\Program Files\Maven",
    "C:\Program Files\Apache\Maven",
    "C:\Program Files (x86)\Apache\Maven",
    "$env:USERPROFILE\.m2\wrapper\dists\apache-maven-3.9.6-bin\3311e1d4\apache-maven-3.9.6"
)

$mavenHome = $null
foreach ($location in $mavenLocations) {
    if (Test-Path "$location\bin\mvn.cmd") {
        $mavenHome = $location
        break
    }
}

if ($mavenHome) {
    Write-Host "✓ Maven found at: $mavenHome" -ForegroundColor Green
    
    if ($isAdmin) {
        [System.Environment]::SetEnvironmentVariable('MAVEN_HOME', $mavenHome, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "✓ MAVEN_HOME set permanently" -ForegroundColor Green
    } else {
        $env:MAVEN_HOME = $mavenHome
        Write-Host "✓ MAVEN_HOME set for current session" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Maven not found" -ForegroundColor Yellow
    Write-Host "  You can use Maven Wrapper (mvnw) instead" -ForegroundColor Yellow
    Write-Host "  Or download Maven from: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
}

# Step 3: Update PATH
Write-Host "`n[3/4] Updating PATH..." -ForegroundColor Yellow

if ($isAdmin) {
    $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
    $pathsToAdd = @()
    
    if ($javaHome -and $currentPath -notlike "*$javaHome\bin*") {
        $pathsToAdd += "$javaHome\bin"
    }
    
    if ($mavenHome -and $currentPath -notlike "*$mavenHome\bin*") {
        $pathsToAdd += "$mavenHome\bin"
    }
    
    if ($pathsToAdd.Count -gt 0) {
        $newPath = $currentPath + ";" + ($pathsToAdd -join ";")
        [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Host "✓ PATH updated permanently" -ForegroundColor Green
        
        # Update current session
        $env:Path = $newPath
    } else {
        Write-Host "✓ PATH already contains required entries" -ForegroundColor Green
    }
} else {
    # Update only current session
    if ($javaHome) {
        $env:Path += ";$javaHome\bin"
    }
    if ($mavenHome) {
        $env:Path += ";$mavenHome\bin"
    }
    Write-Host "✓ PATH updated for current session" -ForegroundColor Yellow
}

# Step 4: Verify Installation
Write-Host "`n[4/4] Verifying installation..." -ForegroundColor Yellow

try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Java verification failed" -ForegroundColor Red
}

if ($mavenHome) {
    try {
        $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven"
        Write-Host "✓ Maven: $mavenVersion" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Maven verification failed (try restarting terminal)" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($isAdmin) {
    Write-Host "✓ Environment variables set permanently" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Close and reopen your terminal" -ForegroundColor White
    Write-Host "2. Navigate to kernel-component directory" -ForegroundColor White
    Write-Host "3. Run: mvn clean package" -ForegroundColor White
} else {
    Write-Host "⚠️  Changes are temporary (current session only)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To make changes permanent:" -ForegroundColor Cyan
    Write-Host "1. Run this script as Administrator" -ForegroundColor White
    Write-Host "2. Right-click PowerShell → 'Run as Administrator'" -ForegroundColor White
}

Write-Host ""
Write-Host "Environment Variables Set:" -ForegroundColor Cyan
Write-Host "  JAVA_HOME  = $javaHome" -ForegroundColor White
if ($mavenHome) {
    Write-Host "  MAVEN_HOME = $mavenHome" -ForegroundColor White
}
Write-Host ""

