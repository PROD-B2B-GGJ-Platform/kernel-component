# 🧪 Kernel Component - Quick Test Guide

**Application Status:** ✅ RUNNING on port 8083

---

## ✅ **Working Endpoints:**

### 1️⃣ **Health Check**
```powershell
Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"
```
**Expected:** `{"status":"UP"}`

---

### 2️⃣ **Create a Kernel Object** ✅ WORKING!

```powershell
$body = @{
    tenantId = "00000000-0000-0000-0000-000000000001"
    objectTypeCode = "CANDIDATE"
    objectCode = "CAND-$(Get-Random -Maximum 9999)"
    data = @{
        firstName = "John"
        lastName = "Doe"
        email = "john.doe@test.com"
        skills = @("Java", "Spring Boot")
        experience = 5
    }
    metadata = @{
        source = "Test"
    }
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/kernel/objects" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

Write-Host "✅ Created Object: $($response.id)"
$response | ConvertTo-Json -Depth 5
```

**This works!** You'll get back:
- `id` - Object UUID
- `version` - Version number (starts at 1)
- `status` - Status of the object
- `createdAt` - Timestamp
- `createdBy` - Creator (system)

---

### 3️⃣ **List All Objects**

```powershell
$objects = Invoke-RestMethod `
    -Uri "http://localhost:8083/api/v1/kernel/objects?page=0&size=10" `
    -Method GET

Write-Host "Total Objects: $($objects.totalElements)"
$objects.content | ForEach-Object {
    Write-Host "  • [$($_.objectTypeCode)] $($_.id) - v$($_.version)"
}
```

---

### 4️⃣ **Access H2 Database Console**

**Open in browser:** http://localhost:8083/h2-console

**Login Credentials:**
- **JDBC URL:** `jdbc:h2:mem:kernel_dev`
- **Username:** `sa`
- **Password:** *(leave blank)*

**Tables to explore:**
```sql
SELECT * FROM GGJ_KERNEL_OBJECTS;
SELECT * FROM GGJ_OBJECT_VERSIONS;
SELECT * FROM GGJ_OBJECT_RELATIONSHIPS;
```

---

## 📊 **Complete Test Script**

Save this as `test-kernel.ps1`:

```powershell
# Kernel Component - Quick Test Script

Write-Host "`n🧪 KERNEL COMPONENT TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Health Check
Write-Host "[1/3] Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"
    Write-Host "✅ Health: $($health.status)`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Application not running!`n" -ForegroundColor Red
    exit 1
}

# 2. Create Object
Write-Host "[2/3] Creating Test Object..." -ForegroundColor Yellow
$createBody = @{
    tenantId = "00000000-0000-0000-0000-000000000001"
    objectTypeCode = "CANDIDATE"
    objectCode = "CAND-$(Get-Random -Maximum 9999)"
    data = @{
        firstName = "Jane"
        lastName = "Smith"
        email = "jane.smith@example.com"
        skills = @("Python", "Django", "REST APIs")
        experience = 3
    }
    metadata = @{
        source = "QuickTest"
        testRun = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
} | ConvertTo-Json -Depth 5

try {
    $created = Invoke-RestMethod `
        -Uri "http://localhost:8083/api/v1/kernel/objects" `
        -Method POST `
        -ContentType "application/json" `
        -Body $createBody
    
    Write-Host "✅ Object Created!" -ForegroundColor Green
    Write-Host "   ID: $($created.id)" -ForegroundColor Cyan
    Write-Host "   Version: $($created.version)" -ForegroundColor Cyan
    Write-Host "   Created At: $($created.createdAt)`n" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Creation Failed: $($_.Exception.Message)`n" -ForegroundColor Red
}

# 3. List Objects
Write-Host "[3/3] Listing All Objects..." -ForegroundColor Yellow
try {
    $list = Invoke-RestMethod `
        -Uri "http://localhost:8083/api/v1/kernel/objects?page=0&size=20" `
        -Method GET
    
    Write-Host "✅ Found $($list.totalElements) object(s)" -ForegroundColor Green
    
    if ($list.totalElements -gt 0) {
        Write-Host "`nObjects:" -ForegroundColor Cyan
        $list.content | ForEach-Object {
            Write-Host "  • [$($_.objectTypeCode)] $($_.objectCode)" -ForegroundColor Yellow
            Write-Host "    ID: $($_.id)" -ForegroundColor Gray
            Write-Host "    Version: $($_.version) | Status: $($_.status)" -ForegroundColor Gray
            Write-Host ""
        }
    }
} catch {
    Write-Host "❌ List Failed: $($_.Exception.Message)`n" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ TEST COMPLETE!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "   • H2 Console: http://localhost:8083/h2-console" -ForegroundColor Yellow
Write-Host "   • View TESTING-GUIDE.md for more examples" -ForegroundColor Yellow
Write-Host ""
```

---

## 🎯 **Quick Commands:**

```powershell
# Create an object
$body = @{ tenantId = "00000000-0000-0000-0000-000000000001"; objectTypeCode = "USER"; objectCode = "USER-001"; data = @{ name = "Test" } } | ConvertTo-Json -Depth 5
Invoke-RestMethod -Uri "http://localhost:8083/api/v1/kernel/objects" -Method POST -ContentType "application/json" -Body $body

# List all objects
Invoke-RestMethod -Uri "http://localhost:8083/api/v1/kernel/objects?page=0&size=10"

# Check health
Invoke-RestMethod -Uri "http://localhost:8083/actuator/health"
```

---

## 🔧 **Application Info:**

- **Port:** 8083
- **Profile:** dev (H2 in-memory database)
- **Database:** jdbc:h2:mem:kernel_dev
- **Features:** Universal Object Storage with Versioning
- **Redis/Kafka:** Disabled in dev mode

---

## ✅ **What's Working:**

✅ Application starts successfully  
✅ H2 Database is running  
✅ JPA entities auto-created  
✅ Health endpoint  
✅ **Object Creation (POST)** - VERIFIED WORKING!  
✅ Object Listing (GET with pagination)  
✅ H2 Console access  

---

## 🚀 **You're All Set!**

The Kernel Component is fully operational. You can now:
1. Create objects with dynamic data
2. Store any JSON structure
3. Track versions automatically
4. Query the H2 database
5. Build on top of this foundation

**Happy Testing!** 🎉

