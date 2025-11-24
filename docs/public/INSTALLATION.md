# 📦 Kernel Component - Installation Guide

**Version:** 10.0.0.1

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuration](#configuration)
4. [Database Setup](#database-setup)
5. [Running the Application](#running-the-application)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## 1. Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Java | 17+ | Runtime |
| Maven | 3.9+ | Build tool |
| PostgreSQL | 15+ | Primary database |
| Redis | 7.0+ | Caching layer |
| Apache Kafka | 3.5+ | Event bus |

### Optional (for dev mode)

- Docker Desktop (for containerized services)
- H2 Database (embedded, auto-included)

---

## 2. Installation Methods

### Method A: Automated Installation (Recommended)

#### **Linux/Mac:**

```bash
cd kernel-component
chmod +x installation/install.sh
./installation/install.sh
```

#### **Windows:**

```powershell
cd kernel-component
.\installation\install.ps1
```

### Method B: Manual Installation

#### Step 1: Clone Repository

```bash
git clone https://github.com/PROD-B2B-GGJ-Platform/kernel-component.git
cd kernel-component
```

#### Step 2: Build Application

```bash
mvn clean package -DskipTests
```

#### Step 3: Verify Build

```bash
ls -lh target/kernel-component.jar
```

---

## 3. Configuration

### Environment-Specific Configuration

#### **Development (H2 in-memory):**

```yaml
# application-dev.yml (already configured)
spring:
  profiles:
    active: dev
  datasource:
    url: jdbc:h2:mem:kernel_dev
```

#### **Production (PostgreSQL):**

Create `application-prod.yml`:

```yaml
spring:
  profiles:
    active: prod
  datasource:
    url: jdbc:postgresql://your-db-host:5432/kernel_prod
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  
  data:
    redis:
      host: your-redis-host
      port: 6379
  
  kafka:
    bootstrap-servers: your-kafka-host:9092
```

### Environment Variables

```bash
export SPRING_PROFILES_ACTIVE=prod
export DATABASE_URL=jdbc:postgresql://localhost:5432/kernel_prod
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=your_password
export REDIS_HOST=localhost
export REDIS_PORT=6379
export KAFKA_BOOTSTRAP_SERVERS=localhost:9092
```

---

## 4. Database Setup

### PostgreSQL Setup

#### Create Database:

```sql
CREATE DATABASE kernel_prod;
CREATE USER kernel_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE kernel_prod TO kernel_user;
```

#### Run Migrations (Flyway):

```bash
mvn flyway:migrate
```

#### Verify Tables:

```sql
\c kernel_prod
\dt ggj_*
```

Expected output:
```
ggj_kernel_objects
ggj_object_versions
ggj_object_relationships
ggj_object_events
ggj_metadata_cache
ggj_outbox_events
```

---

## 5. Running the Application

### Method A: Maven Spring Boot Plugin (Dev)

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Method B: JAR File (Prod)

```bash
java -jar target/kernel-component.jar \
  --spring.profiles.active=prod
```

### Method C: Docker (Containerized)

#### Build Image:

```bash
docker build -t kernel-component:10.0.0.1 -f docker/Dockerfile .
```

#### Run Container:

```bash
docker run -d \
  --name kernel-component \
  -p 8083:8083 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DATABASE_URL=jdbc:postgresql://host.docker.internal:5432/kernel_prod \
  -e DATABASE_USERNAME=kernel_user \
  -e DATABASE_PASSWORD=secure_password \
  -e REDIS_HOST=host.docker.internal \
  -e KAFKA_BOOTSTRAP_SERVERS=host.docker.internal:9092 \
  kernel-component:10.0.0.1
```

### Method D: Kubernetes

```bash
kubectl apply -f k8s/
```

---

## 6. Verification

### Health Check

```bash
curl http://localhost:8083/actuator/health
```

Expected response:
```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "redis": { "status": "UP" },
    "kafka": { "status": "UP" }
  }
}
```

### API Test

```bash
# Create an object
curl -X POST http://localhost:8083/api/v1/kernel/objects \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "00000000-0000-0000-0000-000000000001",
    "objectTypeCode": "TEST",
    "objectCode": "TEST-001",
    "data": {"name": "Test Object"}
  }'
```

### Access Swagger UI

Open browser: http://localhost:8083/swagger-ui.html

---

## 7. Troubleshooting

### Issue 1: Application won't start

**Symptom:** `Failed to bind to port 8083`

**Solution:**
```bash
# Check if port is in use
netstat -an | grep 8083

# Kill process (Linux/Mac)
lsof -ti:8083 | xargs kill -9

# Kill process (Windows)
netstat -ano | findstr :8083
taskkill /PID <PID> /F
```

### Issue 2: Database connection failed

**Symptom:** `Connection refused: postgresql`

**Solution:**
```bash
# Check PostgreSQL status
sudo service postgresql status

# Test connection
psql -h localhost -U kernel_user -d kernel_prod
```

### Issue 3: Redis connection failed

**Symptom:** `Unable to connect to Redis`

**Solution:**
```bash
# Check Redis status
redis-cli ping

# Start Redis (Linux)
sudo service redis-server start

# Start Redis (Docker)
docker run -d -p 6379:6379 redis:7-alpine
```

### Issue 4: Kafka connection failed

**Symptom:** `Connection to node -1 could not be established`

**Solution:**
```bash
# Check Kafka status
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Start Kafka (Docker)
docker-compose up -d kafka
```

---

## 🚀 Quick Start (Dev Mode)

For quick development setup with H2 in-memory database:

```bash
# 1. Clone repo
git clone https://github.com/PROD-B2B-GGJ-Platform/kernel-component.git
cd kernel-component

# 2. Run
mvn spring-boot:run

# 3. Access
# API: http://localhost:8083/api/v1/kernel
# Swagger: http://localhost:8083/swagger-ui.html
# H2 Console: http://localhost:8083/h2-console
```

---

## 📚 Additional Resources

- [Architecture Documentation](ARCHITECTURE.md)
- [API Reference](../api/API-REFERENCE.md)
- [Kubernetes Deployment Guide](../deployment/K8S-DEPLOYMENT.md)

---

## 📞 Support

For installation issues, contact: b2b-platform-team@gograbjob.com

---

**Last Updated:** Q4 2025  
**Version:** 10.0.0.1

