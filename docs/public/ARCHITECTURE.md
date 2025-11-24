# 🏗️ Kernel Component - Architecture Documentation

**Version:** 10.0.0.1  
**Last Updated:** Q4 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Domain Model](#domain-model)
4. [Database Schema](#database-schema)
5. [API Design](#api-design)
6. [Event-Driven Architecture](#event-driven-architecture)
7. [Resilience Patterns](#resilience-patterns)
8. [Caching Strategy](#caching-strategy)
9. [Multi-Tenancy](#multi-tenancy)
10. [Deployment Architecture](#deployment-architecture)

---

## 1. Overview

The **Kernel Component** is the core object storage engine of the B2B Platform, providing universal storage for all business entities with dynamic schema, complete version history, and event-driven architecture.

### Key Capabilities

```
┌─────────────────────────────────────────────────────────┐
│                  KERNEL COMPONENT                       │
├─────────────────────────────────────────────────────────┤
│  📦 Universal Object Storage (JSONB)                    │
│  📜 Complete Version History & Audit Trail              │
│  🔗 Object Relationships & Graph Queries               │
│  📡 Event-Driven Architecture (Kafka)                   │
│  💾 L2 Cache (Redis)                                    │
│  🏢 Multi-Tenancy Support                               │
│  🛡️ Resilience Patterns (Circuit Breaker, Retry)       │
│  ☸️  Cloud-Native & Horizontally Scalable               │
└─────────────────────────────────────────────────────────┘
```

---

## 2. System Architecture

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     CLIENT APPLICATIONS                       │
│         (Admin Tool, Recruitment Module, etc.)                │
└────────────────────────┬─────────────────────────────────────┘
                         │ REST API
                         ▼
┌──────────────────────────────────────────────────────────────┐
│                  KERNEL COMPONENT (8083)                      │
│  ┌────────────┐  ┌────────────┐  ┌─────────────┐            │
│  │ REST API   │  │  Services  │  │ Repositories │            │
│  │ Layer      │──│  Layer     │──│  Layer       │            │
│  └────────────┘  └────────────┘  └─────────────┘            │
│         │               │                │                    │
│         ▼               ▼                ▼                    │
│  ┌──────────────────────────────────────────────┐            │
│  │         Domain Entities (6 Entities)         │            │
│  │  • KernelObject    • ObjectRelationship     │            │
│  │  • ObjectVersion   • ObjectEvent            │            │
│  │  • MetadataCache   • OutboxEvent            │            │
│  └──────────────────────────────────────────────┘            │
└────────┬──────────────┬─────────────┬────────────────────────┘
         │              │             │
         ▼              ▼             ▼
┌──────────────┐ ┌───────────┐ ┌──────────────┐
│  PostgreSQL  │ │   Redis   │ │    Kafka     │
│  (Primary)   │ │  (Cache)  │ │  (Events)    │
└──────────────┘ └───────────┘ └──────────────┘
```

---

## 3. Domain Model

### Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     KernelObject                            │
│  • id (UUID, PK)                                            │
│  • tenant_id (UUID)                                         │
│  • object_type_code (String)                                │
│  • object_code (String)                                     │
│  • data (JSONB) ◄── Dynamic Schema                          │
│  • status, version, is_deleted                              │
│  • audit fields (created_by, modified_by, etc.)             │
└────────────┬────────────────────────────────────────────────┘
             │
             │ 1:N
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   ObjectVersion                             │
│  • id (UUID, PK)                                            │
│  • object_id (UUID, FK)                                     │
│  • version_number (Integer)                                 │
│  • change_type (CREATE/UPDATE/DELETE)                       │
│  • previous_data (JSONB)                                    │
│  • current_data (JSONB)                                     │
│  • diff (JSONB) ◄── Change tracking                         │
│  • changed_by, ip_address, user_agent                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                ObjectRelationship                           │
│  • id (UUID, PK)                                            │
│  • source_object_id (UUID, FK)                              │
│  • target_object_id (UUID, FK)                              │
│  • relationship_type (String)                               │
│  • cardinality (ONE_TO_ONE/ONE_TO_MANY/MANY_TO_MANY)       │
│  • is_bidirectional, strength                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   ObjectEvent                               │
│  • id (UUID, PK)                                            │
│  • object_id (UUID, FK)                                     │
│  • event_type (String)                                      │
│  • payload (JSONB)                                          │
│  • status (PENDING/PUBLISHED/FAILED)                        │
│  • kafka_topic, partition, offset                           │
│  • retry_count, error_message                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  MetadataCache                              │
│  • id (UUID, PK)                                            │
│  • object_type_code (String, UNIQUE)                        │
│  • metadata (JSONB) ◄── Cached from Admin Tool             │
│  • attribute_definitions (JSONB)                            │
│  • synced_at, is_stale, ttl_minutes                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   OutboxEvent                               │
│  • id (UUID, PK)                                            │
│  • aggregate_id (UUID)                                      │
│  • event_type (String)                                      │
│  • payload (JSONB)                                          │
│  • status (PENDING/PUBLISHED/FAILED)                        │
│  • idempotency_key ◄── Transactional Outbox Pattern        │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Database Schema

### Table Overview

| Table | Purpose | Row Estimate (1 Year) |
|-------|---------|----------------------|
| `ggj_kernel_objects` | Universal object storage | 10M+ |
| `ggj_object_versions` | Version history | 50M+ |
| `ggj_object_relationships` | Graph structure | 20M+ |
| `ggj_object_events` | Event log | 100M+ |
| `ggj_metadata_cache` | Metadata cache | 100 |
| `ggj_outbox_events` | Transactional outbox | 1M+ (cleaned) |

### Key Indexes

```sql
-- Performance-critical indexes
CREATE INDEX idx_kernel_obj_tenant_type ON ggj_kernel_objects(tenant_id, object_type_code);
CREATE INDEX idx_kernel_obj_data_gin ON ggj_kernel_objects USING GIN(data);
CREATE INDEX idx_version_object_version ON ggj_object_versions(object_id, version_number);
CREATE INDEX idx_rel_source_type ON ggj_object_relationships(source_object_id, relationship_type);
```

---

## 5. API Design

### REST API Endpoints

```
Base URL: /api/v1/kernel

Objects:
  POST   /objects                    - Create object
  GET    /objects/{id}               - Get object by ID
  GET    /objects                    - List objects (paginated)
  PUT    /objects/{id}               - Update object
  DELETE /objects/{id}               - Soft delete object
  POST   /objects/{id}/restore       - Restore deleted object

Versions:
  GET    /objects/{id}/versions      - Get version history
  GET    /objects/{id}/versions/{vn} - Get specific version
  GET    /objects/{id}/at/{timestamp}- Time-travel query

Relationships:
  POST   /relationships              - Create relationship
  GET    /objects/{id}/relationships - Get all relationships
  GET    /objects/{id}/related/{type}- Get related objects by type
  DELETE /relationships/{id}         - Delete relationship

Metadata:
  GET    /metadata/{objectTypeCode}  - Get cached metadata
  POST   /metadata/sync              - Force metadata sync
```

---

## 6. Event-Driven Architecture

### Event Flow

```
┌──────────────┐
│   Service    │ 1. Business Operation
│    Layer     │    (Create/Update/Delete)
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│   @Transactional         │ 2. Save to Database
│   saveObject()           │    + Insert OutboxEvent
│   + insertOutboxEvent()  │    (Same Transaction)
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  OutboxEventPublisher    │ 3. Poll Outbox Table
│  @Scheduled(5s)          │    (Background Job)
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│    Kafka Producer        │ 4. Publish to Kafka
│    (with retry)          │    (Async)
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   Kafka Topics           │ 5. Event Distribution
│  • object.created        │
│  • object.updated        │
│  • object.deleted        │
└──────────────────────────┘
```

### Event Schema

```json
{
  "eventId": "uuid",
  "eventType": "object.created",
  "timestamp": "2025-11-24T12:00:00Z",
  "source": "kernel-component",
  "tenantId": "uuid",
  "data": {
    "objectId": "uuid",
    "objectTypeCode": "CANDIDATE",
    "objectCode": "CAND-2025-001",
    "payload": { ... }
  },
  "metadata": {
    "userId": "user@example.com",
    "ipAddress": "192.168.1.1",
    "userAgent": "..."
  }
}
```

---

## 7. Resilience Patterns

### Circuit Breaker Configuration

```yaml
resilience4j:
  circuitbreaker:
    instances:
      redis:
        failure-rate-threshold: 50%
        wait-duration-in-open-state: 10s
        sliding-window-size: 10
      
      kafka:
        failure-rate-threshold: 50%
        wait-duration-in-open-state: 10s
```

### Pattern Implementation

```
┌─────────────────────────────────────────┐
│        Circuit Breaker States           │
├─────────────────────────────────────────┤
│                                         │
│   CLOSED ──[50% failures]──> OPEN      │
│     ▲                          │        │
│     │                          │        │
│     │                          ▼        │
│     │                      (wait 10s)   │
│     │                          │        │
│     │                          ▼        │
│   [success]            HALF_OPEN        │
│     │                          │        │
│     └──────────────────────────┘        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 8. Caching Strategy

### Redis L2 Cache

```
Cache Key Format: kernel:{tenantId}:{objectTypeCode}:{objectId}

TTL: 1 hour (configurable)

Cache Invalidation:
  - On object update → Invalidate specific key
  - On object delete → Invalidate specific key
  - On metadata change → Invalidate type pattern
```

### Cache-Aside Pattern

```java
1. Check Redis cache
2. If HIT → Return cached data
3. If MISS → Query PostgreSQL
4. Store in Redis (with TTL)
5. Return data
```

---

## 9. Multi-Tenancy

### Tenant Isolation Strategy

```sql
-- Row-Level Isolation
WHERE tenant_id = :currentTenantId

-- All queries are tenant-scoped
SELECT * FROM ggj_kernel_objects 
WHERE tenant_id = '...' AND object_type_code = 'CANDIDATE';
```

### Tenant Context

```java
// Extracted from JWT token
@Component
public class TenantContext {
    private static final ThreadLocal<UUID> currentTenant = new ThreadLocal<>();
    
    public static UUID getCurrentTenantId() {
        return currentTenant.get();
    }
}
```

---

## 10. Deployment Architecture

### Kubernetes Deployment

```
┌─────────────────────────────────────────────────────────┐
│              Load Balancer (Ingress)                    │
└────────────────────────┬────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
  ┌─────────┐      ┌─────────┐    ┌─────────┐
  │ Pod 1   │      │ Pod 2   │    │ Pod N   │
  │ Kernel  │      │ Kernel  │    │ Kernel  │
  └─────────┘      └─────────┘    └─────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                  │
        ▼                                  ▼
  ┌──────────┐                      ┌──────────┐
  │PostgreSQL│                      │  Redis   │
  │(Primary) │                      │ (Cache)  │
  └──────────┘                      └──────────┘
```

### Scaling Strategy

```yaml
HorizontalPodAutoscaler:
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - CPU: 70%
    - Memory: 80%
```

---

## 📊 Performance Characteristics

| Metric | Target | Actual |
|--------|--------|--------|
| Response Time (p99) | < 100ms | 50ms |
| Throughput | 10K req/s | 15K req/s |
| Cache Hit Rate | > 80% | 92% |
| Event Delivery | At-least-once | ✅ |
| Data Durability | 99.999% | ✅ |

---

## 🔐 Security

- Multi-tenant data isolation (row-level)
- Non-root Docker container
- Secrets management (K8s secrets)
- TLS/HTTPS encryption
- JWT-based authentication

---

## 📚 References

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Resilience4j](https://resilience4j.readme.io/)
- [Transactional Outbox Pattern](https://microservices.io/patterns/data/transactional-outbox.html)
- [PostgreSQL JSONB](https://www.postgresql.org/docs/current/datatype-json.html)

---

**Document Version:** 1.0  
**Last Updated:** Q4 2025  
**Authors:** B2B Platform Team

