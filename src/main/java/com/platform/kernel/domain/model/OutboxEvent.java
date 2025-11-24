package com.platform.kernel.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Outbox Event Entity - Transactional Outbox Pattern
 * 
 * Ensures reliable event publishing with database transaction guarantees.
 * 
 * Pattern:
 * 1. Object changes and outbox event are saved in SAME transaction
 * 2. Background job polls outbox and publishes to Kafka
 * 3. Guarantees at-least-once delivery
 * 4. Idempotency handled by consumers
 * 
 * Benefits:
 * - No lost events (even if Kafka is down)
 * - Transactional consistency
 * - Event replay capability
 * - Resilience to failures
 */
@Entity
@Table(name = "ggj_outbox_events",
       indexes = {
           @Index(name = "idx_outbox_status", columnList = "status"),
           @Index(name = "idx_outbox_created", columnList = "created_at"),
           @Index(name = "idx_outbox_status_created", columnList = "status, created_at"),
           @Index(name = "idx_outbox_aggregate", columnList = "aggregate_id"),
           @Index(name = "idx_outbox_next_retry", columnList = "next_retry_at")
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class OutboxEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Aggregate ID (usually object ID)
     */
    @Column(name = "aggregate_id", nullable = false)
    private UUID aggregateId;

    /**
     * Aggregate type (e.g., "KernelObject", "ObjectRelationship")
     */
    @Column(name = "aggregate_type", nullable = false, length = 100)
    private String aggregateType;

    /**
     * Event type
     */
    @Column(name = "event_type", nullable = false, length = 100)
    private String eventType;

    /**
     * Event payload (full event data)
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "payload", columnDefinition = "jsonb", nullable = false)
    private Map<String, Object> payload;

    /**
     * Status: PENDING, PUBLISHED, FAILED
     */
    @Column(name = "status", nullable = false, length = 50)
    @Builder.Default
    private String status = "PENDING";

    /**
     * Retry count
     */
    @Column(name = "retry_count", nullable = false)
    @Builder.Default
    private Integer retryCount = 0;

    /**
     * Maximum retries
     */
    @Column(name = "max_retries", nullable = false)
    @Builder.Default
    private Integer maxRetries = 5;

    /**
     * Last error message
     */
    @Column(name = "error_message", length = 2000)
    private String errorMessage;

    /**
     * When published to Kafka
     */
    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    /**
     * Kafka topic
     */
    @Column(name = "kafka_topic", length = 200)
    private String kafkaTopic;

    /**
     * Kafka partition
     */
    @Column(name = "kafka_partition")
    private Integer kafkaPartition;

    /**
     * Kafka offset
     */
    @Column(name = "kafka_offset")
    private Long kafkaOffset;

    /**
     * Next scheduled retry
     */
    @Column(name = "next_retry_at")
    private LocalDateTime nextRetryAt;

    /**
     * Idempotency key (to prevent duplicate processing)
     */
    @Column(name = "idempotency_key", length = 100)
    private String idempotencyKey;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // === Status Constants ===
    
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PUBLISHED = "PUBLISHED";
    public static final String STATUS_FAILED = "FAILED";

    // === Helper Methods ===

    /**
     * Mark as published
     */
    public void markAsPublished(String topic, Integer partition, Long offset) {
        this.status = STATUS_PUBLISHED;
        this.publishedAt = LocalDateTime.now();
        this.kafkaTopic = topic;
        this.kafkaPartition = partition;
        this.kafkaOffset = offset;
    }

    /**
     * Mark as failed and schedule retry
     */
    public void markAsFailed(String errorMessage) {
        this.status = STATUS_FAILED;
        this.errorMessage = errorMessage;
        this.retryCount++;
        
        if (canRetry()) {
            // Exponential backoff: 1m, 2m, 4m, 8m, 16m
            long backoffMinutes = (long) Math.pow(2, this.retryCount);
            this.nextRetryAt = LocalDateTime.now().plusMinutes(backoffMinutes);
        }
    }

    /**
     * Check if can be retried
     */
    public boolean canRetry() {
        return retryCount < maxRetries;
    }

    /**
     * Check if ready for retry
     */
    public boolean isReadyForRetry() {
        return STATUS_FAILED.equals(status) &&
               canRetry() &&
               (nextRetryAt == null || LocalDateTime.now().isAfter(nextRetryAt));
    }

    /**
     * Generate idempotency key
     */
    public void generateIdempotencyKey() {
        this.idempotencyKey = aggregateType + ":" + aggregateId + ":" + eventType + ":" + createdAt;
    }

    @Override
    public String toString() {
        return "OutboxEvent{" +
                "id=" + id +
                ", aggregateId=" + aggregateId +
                ", aggregateType='" + aggregateType + '\'' +
                ", eventType='" + eventType + '\'' +
                ", status='" + status + '\'' +
                ", retryCount=" + retryCount +
                '}';
    }
}

