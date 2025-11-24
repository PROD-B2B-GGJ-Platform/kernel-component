# 🚀 Kernel Component

**Version:** 10.0.0.1  
**Cluster:** Kernel Cluster  
**Type:** Core Service  
**Technology:** Java 17 + Spring Boot 3.2

---

## 📋 Overview

The **Kernel Component** is the core object storage engine of the B2B Platform. It provides:

- ✅ **Universal Object Storage** with dynamic JSONB schema
- ✅ **Complete Version History** and audit trail
- ✅ **Object Relationships** and graph queries
- ✅ **Event-Driven Architecture** (Kafka)
- ✅ **L2 Caching** (Redis)
- ✅ **Multi-Tenancy** support
- ✅ **Resilience Patterns** (Circuit Breaker, Retry, Bulkhead)
- ✅ **Cloud-Native** and horizontally scalable

---

## 🏗️ Architecture

```
kernel-component/
├── Domain Entities (6)
│   ├── KernelObject (universal storage)
│   ├── ObjectVersion (version history)
│   ├── ObjectRelationship (graph)
│   ├── ObjectEvent (Kafka log)
│   ├── MetadataCache (autonomy)
│   └── OutboxEvent (transactional outbox)
│
├── Repositories (6)
├── Services (4+)
├── REST API (OpenAPI)
├── Configuration (Resilience4j, Kafka, Redis)
└── Database Migrations (Flyway)
```

---

## 🚀 Quick Start

### **Prerequisites**

- Java 17+
- Maven 3.9+
- PostgreSQL 15+
- Redis 7+
- Kafka 3.5+

**📖 For detailed environment setup (including Maven installation), see:**
- **[Environment Setup Guide](docs/public/ENVIRONMENT-SETUP.md)** - Complete guide for Windows/Linux/Mac
- **Quick Setup Script:** Run `.\scripts\setup-environment.ps1` (Windows) or `./scripts/setup-environment.sh` (Linux/Mac)

### **Build**

```bash
mvn clean package
```

### **Run (Dev Mode)**

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### **Access**

- **API**: http://localhost:8083/api/v1/kernel
- **Swagger**: http://localhost:8083/swagger-ui.html
- **Health**: http://localhost:8083/actuator/health
- **Metrics**: http://localhost:8083/actuator/prometheus

---

## 🐳 Docker

### **Build Image**

```bash
docker build -t kernel-component:10.0.0.1 -f docker/Dockerfile .
```

### **Run Container**

```bash
docker run -p 8083:8083 \
  -e SPRING_PROFILES_ACTIVE=dev \
  -e DATABASE_URL=jdbc:postgresql://host.docker.internal:5432/kernel_db \
  kernel-component:10.0.0.1
```

---

## ☸️ Kubernetes Deployment

### **Apply Manifests**

```bash
kubectl apply -f k8s/
```

### **Check Status**

```bash
kubectl get pods -l app=kernel-component
kubectl logs -f <pod-name>
```

---

## 📊 API Documentation

Full API documentation available at:
- **OpenAPI Spec**: http://localhost:8083/api-docs
- **Swagger UI**: http://localhost:8083/swagger-ui.html

---

## 🔧 Configuration

### **Environment Variables**

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Active profile (dev/prod) | `dev` |
| `DATABASE_URL` | PostgreSQL connection URL | `jdbc:postgresql://localhost:5432/kernel_db` |
| `REDIS_HOST` | Redis host | `localhost` |
| `REDIS_PORT` | Redis port | `6379` |
| `KAFKA_BOOTSTRAP_SERVERS` | Kafka brokers | `localhost:9092` |

---

## 🧪 Testing

### **Unit Tests**

```bash
mvn test
```

### **Integration Tests**

```bash
mvn verify
```

---

## 📚 Documentation

- **Architecture**: [docs/architecture/COMPONENT-ARCHITECTURE.md](docs/architecture/COMPONENT-ARCHITECTURE.md)
- **API Reference**: [docs/api/API-REFERENCE.md](docs/api/API-REFERENCE.md)
- **Deployment**: [docs/deployment/DEPLOYMENT-GUIDE.md](docs/deployment/DEPLOYMENT-GUIDE.md)

---

## 🤝 Contributing

This is a proprietary component of the B2B Platform.

---

## 📄 License

Proprietary - B2B Platform Team

---

## 📞 Support

For support, contact: b2b-platform-team@gograbjob.com

---

**Built with ❤️ by the B2B Platform Team**

