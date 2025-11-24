# 🔧 Environment Setup Guide

**Version:** 10.0.0.1  
**Last Updated:** Q4 2025

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Java Setup](#java-setup)
3. [Maven Setup](#maven-setup)
4. [Environment Variables](#environment-variables)
5. [IDE Setup](#ide-setup)
6. [Database Setup](#database-setup)
7. [Redis Setup](#redis-setup)
8. [Kafka Setup](#kafka-setup)
9. [Verification](#verification)

---

## 1. Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Java JDK | 17+ | Runtime & Compilation |
| Maven | 3.9+ | Build tool |
| PostgreSQL | 15+ | Production database |
| Redis | 7.0+ | Caching layer |
| Apache Kafka | 3.5+ | Event bus |
| Git | 2.40+ | Version control |

### Optional Software

| Software | Version | Purpose |
|----------|---------|---------|
| Docker Desktop | Latest | Containerization |
| IntelliJ IDEA | 2023.3+ | IDE (recommended) |
| VS Code | Latest | Lightweight IDE |
| Postman | Latest | API testing |

---

## 2. Java Setup

### Download & Install

**Option A: Microsoft OpenJDK (Recommended for Windows)**

1. Download from: https://learn.microsoft.com/en-us/java/openjdk/download
2. Run installer: `microsoft-jdk-17.X.XX-windows-x64.msi`
3. Follow installation wizard

**Option B: Oracle JDK**

1. Download from: https://www.oracle.com/java/technologies/downloads/#java17
2. Install to: `C:\Program Files\Java\jdk-17`

### Verify Installation

```powershell
java -version
```

**Expected Output:**
```
openjdk version "17.0.17" 2024-10-15 LTS
OpenJDK Runtime Environment Microsoft-9617215 (build 17.0.17+10-LTS)
```

---

## 3. Maven Setup

### Download & Install

#### **Method 1: Download Binary (Recommended)**

1. **Download Maven:**
   - Go to: https://maven.apache.org/download.cgi
   - Download: `apache-maven-3.9.6-bin.zip`

2. **Extract:**
   ```powershell
   # Extract to C:\Program Files
   Expand-Archive apache-maven-3.9.6-bin.zip -DestinationPath "C:\Program Files\"
   ```

3. **Rename folder:**
   ```powershell
   Rename-Item "C:\Program Files\apache-maven-3.9.6" "C:\Program Files\Maven"
   ```

#### **Method 2: Use Maven Wrapper (Already included)**

The project includes Maven Wrapper (`mvnw`), so you can use it without installing Maven:

```powershell
.\mvnw clean package
```

### Verify Installation

```powershell
mvn -version
```

**Expected Output:**
```
Apache Maven 3.9.6
Maven home: C:\Program Files\Maven
Java version: 17.0.17, vendor: Microsoft
```

---

## 4. Environment Variables

### Windows Setup (Permanent)

#### **Step 1: Set JAVA_HOME**

```powershell
# Open System Properties (Run as Administrator)
[System.Environment]::SetEnvironmentVariable(
    'JAVA_HOME',
    'C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot',
    [System.EnvironmentVariableTarget]::Machine
)
```

**OR via GUI:**

1. Press `Win + X` → System
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", click "New"
5. Variable name: `JAVA_HOME`
6. Variable value: `C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot`
7. Click OK

#### **Step 2: Set MAVEN_HOME**

```powershell
[System.Environment]::SetEnvironmentVariable(
    'MAVEN_HOME',
    'C:\Program Files\Maven',
    [System.EnvironmentVariableTarget]::Machine
)
```

**OR via GUI:**

1. System → Advanced settings → Environment Variables
2. Under "System variables", click "New"
3. Variable name: `MAVEN_HOME`
4. Variable value: `C:\Program Files\Maven`
5. Click OK

#### **Step 3: Update PATH**

```powershell
# Get current PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

# Add Java and Maven to PATH
$newPath = $currentPath + ';%JAVA_HOME%\bin;%MAVEN_HOME%\bin'

# Set new PATH
[System.Environment]::SetEnvironmentVariable(
    'Path',
    $newPath,
    [System.EnvironmentVariableTarget]::Machine
)
```

**OR via GUI:**

1. System → Advanced settings → Environment Variables
2. Under "System variables", select "Path"
3. Click "Edit"
4. Click "New" and add:
   - `%JAVA_HOME%\bin`
   - `%MAVEN_HOME%\bin`
5. Click OK on all dialogs

#### **Step 4: Restart Terminal**

Close and reopen PowerShell/Command Prompt for changes to take effect.

---

### Linux/Mac Setup

#### **Add to ~/.bashrc or ~/.zshrc:**

```bash
# Java
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# Maven
export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH
```

#### **Apply changes:**

```bash
source ~/.bashrc  # or source ~/.zshrc
```

---

### Temporary Setup (Current Session Only)

**Windows PowerShell:**

```powershell
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
$env:MAVEN_HOME = "C:\Program Files\Maven"
$env:Path += ";$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin"
```

**Linux/Mac:**

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export MAVEN_HOME=/opt/maven
export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH
```

---

## 5. IDE Setup

### IntelliJ IDEA (Recommended)

1. **Install IntelliJ IDEA:**
   - Download: https://www.jetbrains.com/idea/download/

2. **Open Project:**
   - File → Open → Select `kernel-component` folder
   - Wait for Maven import to complete

3. **Configure JDK:**
   - File → Project Structure → Project
   - SDK: Select Java 17
   - Language level: 17

4. **Enable Lombok:**
   - File → Settings → Plugins
   - Search "Lombok" → Install
   - Restart IDE

5. **Run Configuration:**
   - Run → Edit Configurations
   - Add New → Spring Boot
   - Main class: `com.platform.kernel.KernelApplication`
   - Active profiles: `dev`

### VS Code

1. **Install Extensions:**
   - Java Extension Pack
   - Spring Boot Extension Pack
   - Lombok Annotations Support

2. **Configure Java:**
   - Ctrl+Shift+P → "Java: Configure Java Runtime"
   - Select Java 17

---

## 6. Database Setup

### PostgreSQL (Production)

#### **Install:**

**Windows:**
```powershell
# Download installer from: https://www.postgresql.org/download/windows/
# Run: postgresql-15.X-windows-x64.exe
```

**Linux (Ubuntu):**
```bash
sudo apt update
sudo apt install postgresql-15
```

**Mac:**
```bash
brew install postgresql@15
```

#### **Create Database:**

```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create database
CREATE DATABASE kernel_prod;

-- Create user
CREATE USER kernel_user WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE kernel_prod TO kernel_user;

-- Exit
\q
```

#### **Environment Variables:**

```powershell
[System.Environment]::SetEnvironmentVariable('DATABASE_URL', 'jdbc:postgresql://localhost:5432/kernel_prod', 'User')
[System.Environment]::SetEnvironmentVariable('DATABASE_USERNAME', 'kernel_user', 'User')
[System.Environment]::SetEnvironmentVariable('DATABASE_PASSWORD', 'secure_password', 'User')
```

### H2 (Development - Built-in)

No setup required! H2 runs in-memory automatically when using `dev` profile.

---

## 7. Redis Setup

### Docker (Easiest)

```powershell
docker run -d --name redis -p 6379:6379 redis:7-alpine
```

### Windows (Native)

1. Download: https://github.com/microsoftarchive/redis/releases
2. Extract to: `C:\Program Files\Redis`
3. Run: `redis-server.exe`

### Linux

```bash
sudo apt install redis-server
sudo systemctl start redis-server
```

### Environment Variables:

```powershell
[System.Environment]::SetEnvironmentVariable('REDIS_HOST', 'localhost', 'User')
[System.Environment]::SetEnvironmentVariable('REDIS_PORT', '6379', 'User')
```

---

## 8. Kafka Setup

### Docker Compose (Easiest)

Create `docker-compose.yml`:

```yaml
version: '3'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
```

**Start:**
```powershell
docker-compose up -d
```

### Environment Variables:

```powershell
[System.Environment]::SetEnvironmentVariable('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092', 'User')
```

---

## 9. Verification

### Verify All Environment Variables

```powershell
# Windows
echo $env:JAVA_HOME
echo $env:MAVEN_HOME
echo $env:DATABASE_URL
echo $env:REDIS_HOST
echo $env:KAFKA_BOOTSTRAP_SERVERS

# Check PATH
$env:Path -split ';' | Select-String -Pattern 'java|maven'
```

**Linux/Mac:**
```bash
echo $JAVA_HOME
echo $MAVEN_HOME
echo $DATABASE_URL
printenv | grep -E 'JAVA|MAVEN|DATABASE|REDIS|KAFKA'
```

### Verify Software Versions

```powershell
java -version
mvn -version
psql --version
redis-cli --version
docker --version
git --version
```

### Quick Test Build

```powershell
cd kernel-component
mvn clean package -DskipTests
```

**Expected:** `BUILD SUCCESS`

---

## 🚀 Quick Start Script

Save as `setup-env.ps1`:

```powershell
# Kernel Component - Environment Setup Script
Write-Host "Setting up Kernel Component environment..." -ForegroundColor Cyan

# Set Java
$javaHome = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaHome, 'Machine')
Write-Host "✓ JAVA_HOME set to: $javaHome" -ForegroundColor Green

# Set Maven
$mavenHome = "C:\Program Files\Maven"
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME', $mavenHome, 'Machine')
Write-Host "✓ MAVEN_HOME set to: $mavenHome" -ForegroundColor Green

# Update PATH
$path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
if ($path -notlike "*$javaHome\bin*") {
    $path += ";$javaHome\bin"
}
if ($path -notlike "*$mavenHome\bin*") {
    $path += ";$mavenHome\bin"
}
[System.Environment]::SetEnvironmentVariable('Path', $path, 'Machine')
Write-Host "✓ PATH updated" -ForegroundColor Green

Write-Host "`n✅ Environment setup complete!" -ForegroundColor Green
Write-Host "Please restart your terminal for changes to take effect." -ForegroundColor Yellow
```

**Run as Administrator:**
```powershell
.\setup-env.ps1
```

---

## 📝 Environment Variables Reference

### Required (Development)

| Variable | Value | Purpose |
|----------|-------|---------|
| `JAVA_HOME` | `C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot` | Java installation |
| `MAVEN_HOME` | `C:\Program Files\Maven` | Maven installation |

### Optional (Production)

| Variable | Default | Purpose |
|----------|---------|---------|
| `SPRING_PROFILES_ACTIVE` | `dev` | Active profile |
| `DATABASE_URL` | `jdbc:postgresql://localhost:5432/kernel_prod` | Database connection |
| `DATABASE_USERNAME` | `postgres` | Database user |
| `DATABASE_PASSWORD` | (secure) | Database password |
| `REDIS_HOST` | `localhost` | Redis server |
| `REDIS_PORT` | `6379` | Redis port |
| `KAFKA_BOOTSTRAP_SERVERS` | `localhost:9092` | Kafka brokers |

---

## 🐛 Troubleshooting

### Issue: `mvn` command not found

**Solution:**
```powershell
# Check if Maven is in PATH
$env:Path -split ';' | Select-String maven

# If not found, add manually
$env:Path += ";C:\Program Files\Maven\bin"
```

### Issue: `JAVA_HOME` not set

**Solution:**
```powershell
# Set temporarily
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"

# Set permanently (run as admin)
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $env:JAVA_HOME, 'Machine')
```

### Issue: Wrong Java version

**Solution:**
```powershell
# List all Java installations
ls "C:\Program Files\Java"
ls "C:\Program Files\Microsoft"

# Update JAVA_HOME to correct version
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot"
```

---

## 📚 Additional Resources

- **Java Documentation:** https://docs.oracle.com/en/java/javase/17/
- **Maven Documentation:** https://maven.apache.org/guides/
- **Spring Boot Documentation:** https://spring.io/projects/spring-boot
- **PostgreSQL Documentation:** https://www.postgresql.org/docs/15/

---

## 📞 Support

For environment setup issues, contact: b2b-platform-team@gograbjob.com

---

**Last Updated:** Q4 2025  
**Version:** 10.0.0.1

