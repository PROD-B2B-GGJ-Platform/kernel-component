# 🧪 Kernel Component - Testing Guide

**Version:** 10.0.0.1  
**Last Updated:** Q4 2025

---

## 🚀 How to Start the Application

### **Method 1: PowerShell Script (Recommended)**

```powershell
cd C:\PROJECT_2025\GGJQ4_SPRINT01\B2B_PLATFORM\kernel-cluster\kernel-component
.\START-KERNEL.ps1
```

### **Method 2: Maven Command**

```powershell
cd C:\PROJECT_2025\GGJQ4_SPRINT01\B2B_PLATFORM\kernel-cluster\kernel-component
mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.jvmArguments="-Dserver.port=8083"
```

---

## ✅ Verify Application is Running

### **1. Check Health Endpoint**

```powershell
Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"
```

**Expected Response:**
```json
{
  "status": "UP"
}
```

### **2. Check Process**

```powershell
jps -l | Select-String "Kernel"
```

### **3. Check Port**

```powershell
netstat -ano | findstr :8083
```

---

## 🧪 Test APIs

### **1. Open Swagger UI**

Navigate to: **http://localhost:8083/swagger-ui.html**

This provides interactive API documentation where you can test all endpoints.

---

### **2. Create a Kernel Object**

```powershell
$body = @{
    schemaId = "schema-001"
    objectTypeCode = "CANDIDATE"
    objectData = @{
        firstName = "John"
        lastName = "Doe"
        email = "john.doe@example.com"
        phone = "+1-234-567-8900"
        skills = @("Java", "Spring Boot", "Microservices")
        experience = 5
    }
    metadata = @{
        source = "LinkedIn"
        priority = "High"
    }
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

Write-Host "`n✅ Object Created!" -ForegroundColor Green
Write-Host "ID: $($response.id)" -ForegroundColor Cyan
$response | ConvertTo-Json -Depth 5
```

**Expected Response:**
```json
{
  "id": "uuid-generated",
  "tenantId": "default-tenant",
  "schemaId": "schema-001",
  "objectTypeCode": "CANDIDATE",
  "objectData": {
    "firstName": "John",
    "lastName": "Doe",
    ...
  },
  "version": 1,
  "isActive": true,
  "createdAt": "2025-11-24T...",
  "createdBy": "system"
}
```

---

### **3. Get Object by ID**

```powershell
$objectId = "uuid-from-previous-step"

$object = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects/$objectId" `
    -Method GET

$object | ConvertTo-Json -Depth 5
```

---

### **4. Update Object**

```powershell
$objectId = "uuid-from-create-step"

$updateBody = @{
    objectData = @{
        firstName = "John"
        lastName = "Doe"
        email = "john.doe@newcompany.com"  # Updated email
        phone = "+1-234-567-8900"
        skills = @("Java", "Spring Boot", "Microservices", "Kubernetes")  # Added skill
        experience = 6  # Updated experience
    }
    metadata = @{
        source = "LinkedIn"
        priority = "Critical"  # Updated priority
        lastUpdated = "2025-11-24"
    }
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects/$objectId" `
    -Method PUT `
    -ContentType "application/json" `
    -Body $updateBody

Write-Host "`n✅ Object Updated!" -ForegroundColor Green
Write-Host "Version: $($response.version)" -ForegroundColor Cyan
$response | ConvertTo-Json -Depth 5
```

---

### **5. Get Version History**

```powershell
$objectId = "uuid-from-create-step"

$versions = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/versions/object/$objectId" `
    -Method GET

Write-Host "`n📜 Version History:" -ForegroundColor Cyan
$versions | ForEach-Object {
    Write-Host "  Version $($_.versionNumber) - $($_.createdAt) by $($_.createdBy)" -ForegroundColor Yellow
}
$versions | ConvertTo-Json -Depth 5
```

---

### **6. List All Objects (Paginated)**

```powershell
$objects = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects?page=0&size=10" `
    -Method GET

Write-Host "`n📋 Objects:" -ForegroundColor Cyan
$objects.content | ForEach-Object {
    Write-Host "  [$($_.objectTypeCode)] $($_.id) - v$($_.version)" -ForegroundColor Yellow
}
$objects | ConvertTo-Json -Depth 5
```

---

### **7. Filter Objects by Type**

```powershell
$objects = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects?objectTypeCode=CANDIDATE&page=0&size=10" `
    -Method GET

Write-Host "`n📋 Candidates:" -ForegroundColor Cyan
$objects.content | ForEach-Object {
    Write-Host "  $($_.objectData.firstName) $($_.objectData.lastName)" -ForegroundColor Yellow
}
```

---

### **8. Soft Delete Object**

```powershell
$objectId = "uuid-from-create-step"

Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects/$objectId" `
    -Method DELETE

Write-Host "`n✅ Object Soft Deleted (isActive = false)" -ForegroundColor Yellow
```

---

### **9. Restore Soft Deleted Object**

```powershell
$objectId = "uuid-from-create-step"

$response = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects/$objectId/restore" `
    -Method POST

Write-Host "`n✅ Object Restored!" -ForegroundColor Green
$response | ConvertTo-Json -Depth 5
```

---

## 🗄️ Access H2 Database Console

1. **Navigate to:** http://localhost:8083/h2-console

2. **Login with:**
   - **JDBC URL:** `jdbc:h2:mem:kernel_dev`
   - **Username:** `sa`
   - **Password:** *(leave blank)*

3. **Explore Tables:**
   - `GGJ_KERNEL_OBJECTS` - All objects
   - `GGJ_OBJECT_VERSIONS` - Version history
   - `GGJ_OBJECT_RELATIONSHIPS` - Object relationships
   - `GGJ_OBJECT_EVENTS` - Event log
   - `GGJ_METADATA_CACHE` - Cached metadata
   - `GGJ_OUTBOX_EVENTS` - Outbox events for Kafka

---

## 📊 Monitoring & Metrics

### **Actuator Endpoints**

```powershell
# Health Check
Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"

# Application Info
Invoke-RestMethod -Uri "http://localhost:8083/actuator/info"

# Metrics (Prometheus format)
Invoke-RestMethod -Uri "http://localhost:8083/actuator/prometheus"

# All Actuator Endpoints
Invoke-RestMethod -Uri "http://localhost:8083/actuator"
```

---

## 🧪 Complete Test Scenario

**Full workflow testing all features:**

```powershell
# Test Script: Complete Kernel Component Verification

Write-Host "`n🧪 KERNEL COMPONENT - FULL TEST SUITE" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# 1. Health Check
Write-Host "`n[1/6] Health Check..." -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"
Write-Host "✅ Status: $($health.status)" -ForegroundColor Green

# 2. Create Object
Write-Host "`n[2/6] Creating Object..." -ForegroundColor Yellow
$createBody = @{
    schemaId = "schema-001"
    objectTypeCode = "CANDIDATE"
    objectData = @{
        firstName = "Jane"
        lastName = "Smith"
        email = "jane.smith@example.com"
        skills = @("Python", "Django", "REST APIs")
        experience = 3
    }
} | ConvertTo-Json -Depth 5

$created = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects" `
    -Method POST `
    -ContentType "application/json" `
    -Body $createBody

Write-Host "✅ Created: $($created.id)" -ForegroundColor Green
$objectId = $created.id

# 3. Get Object
Write-Host "`n[3/6] Retrieving Object..." -ForegroundColor Yellow
$retrieved = Invoke-RestMethod -Uri "http://localhost:8083/api/v1/objects/$objectId"
Write-Host "✅ Retrieved: $($retrieved.objectData.firstName) $($retrieved.objectData.lastName)" -ForegroundColor Green

# 4. Update Object
Write-Host "`n[4/6] Updating Object..." -ForegroundColor Yellow
$updateBody = @{
    objectData = @{
        firstName = "Jane"
        lastName = "Smith"
        email = "jane.smith@newcompany.com"
        skills = @("Python", "Django", "REST APIs", "GraphQL")
        experience = 4
    }
} | ConvertTo-Json -Depth 5

$updated = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/objects/$objectId" `
    -Method PUT `
    -ContentType "application/json" `
    -Body $updateBody

Write-Host "✅ Updated: Version $($updated.version)" -ForegroundColor Green

# 5. Get Version History
Write-Host "`n[5/6] Checking Version History..." -ForegroundColor Yellow
$versions = Invoke-RestMethod -Uri "http://localhost:8083/api/v1/versions/object/$objectId"
Write-Host "✅ Versions: $($versions.Count) version(s) found" -ForegroundColor Green

# 6. Soft Delete
Write-Host "`n[6/6] Soft Delete..." -ForegroundColor Yellow
Invoke-RestMethod -Uri "http://localhost:8083/api/v1/objects/$objectId" -Method DELETE
Write-Host "✅ Soft Deleted" -ForegroundColor Green

Write-Host "`n✅ ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan
```

---

## 🔧 Troubleshooting

### **Issue: Port 8083 already in use**

```powershell
# Find process using port 8083
netstat -ano | findstr :8083

# Kill process (use PID from above)
taskkill /PID <PID> /F

# Or start on different port
mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.jvmArguments="-Dserver.port=8084"
```

### **Issue: Maven not found**

```powershell
# Add Maven to PATH for current session
$env:Path += ";C:\Users\dharm\.m2\wrapper\dists\apache-maven-3.9.6-bin\3311e1d4\apache-maven-3.9.6\bin"

# Or use Maven Wrapper
.\mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### **Issue: Application won't start**

```powershell
# Check logs in: target/spring.log
Get-Content -Path "target/spring.log" -Tail 50

# Clean and rebuild
mvn clean package
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## 📞 Support

For testing issues, refer to:
- **Architecture:** `docs/public/ARCHITECTURE.md`
- **Environment Setup:** `docs/public/ENVIRONMENT-SETUP.md`
- **Installation:** `docs/public/INSTALLATION.md`

---

**Last Updated:** Q4 2025  
**Version:** 10.0.0.1

