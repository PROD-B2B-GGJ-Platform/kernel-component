package com.platform.kernel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Kernel Component - Core Object Storage Engine
 * 
 * Features:
 * - Universal object storage with dynamic schema (JSONB)
 * - Complete version history and audit trail
 * - Object relationships and graph queries
 * - Event-driven architecture (Kafka)
 * - Redis L2 caching
 * - Multi-tenancy support
 * - Resilience patterns (Circuit Breaker, Retry, Bulkhead)
 * - Cloud-native and horizontally scalable
 * 
 * @author B2B Platform Team
 * @version 10.0.0.1
 */
@SpringBootApplication
@EnableJpaAuditing
@EnableCaching
@EnableKafka
@EnableAsync
@EnableScheduling
public class KernelApplication {

    public static void main(String[] args) {
        SpringApplication.run(KernelApplication.class, args);
        System.out.println("""
            
            ╔═══════════════════════════════════════════════════════════════╗
            ║                                                               ║
            ║     KERNEL COMPONENT - OBJECT STORAGE ENGINE                  ║
            ║                                                               ║
            ║     Version: 10.0.0.1                                        ║
            ║     Cluster: Kernel Cluster                                   ║
            ║     Port: 8083                                               ║
            ║                                                               ║
            ║     Features:                                                 ║
            ║      ✓ Universal Object Storage (JSONB)                      ║
            ║      ✓ Version Control & Audit Trail                         ║
            ║      ✓ Relationships & Graph Queries                         ║
            ║      ✓ Event Bus (Kafka)                                     ║
            ║      ✓ L2 Cache (Redis)                                      ║
            ║      ✓ Multi-Tenancy                                         ║
            ║      ✓ Resilience Patterns                                   ║
            ║      ✓ Cloud-Native & Scalable                               ║
            ║                                                               ║
            ║     API: http://localhost:8083/api/v1/kernel                 ║
            ║     Swagger: http://localhost:8083/swagger-ui.html           ║
            ║     Health: http://localhost:8083/actuator/health            ║
            ║     Metrics: http://localhost:8083/actuator/prometheus       ║
            ║                                                               ║
            ╚═══════════════════════════════════════════════════════════════╝
            """);
    }
}
