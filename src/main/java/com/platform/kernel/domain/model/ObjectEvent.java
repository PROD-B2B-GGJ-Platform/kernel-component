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
 * Object Event Log Entity
 * 
 * Tracks all events published to Kafka event bus.
 * 
 * Features:
 * - Event status tracking (PENDING, PUBLISHED, FAILED)
 * - Retry mechanism
 * - Kafka partition/offset tracking
 * - Event replay capability
 * - Dead letter queue support
 */
@Entity
@Table(name = "ggj_object_events",
       indexes = {
           @Index(name = "idx_event_object_id", columnList = "object_id"),
           @Index(name = "idx_event_status", columnList = "status"),
           @Index(name = "idx_event_type", columnList = "event_type"),
           @Index(name = "idx_event_created", columnList = "created_at"),
           @Index(name = "idx_event_status_created", columnList = "status, created_at")
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class ObjectEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Object ID that triggered the event
     */
    @Column(name = "object_id", nullable = false)
    private UUID objectId;

    /**
     * Event type: object.created, object.updated, object.deleted, etc.
     */
    @Column(name = "event_type", nullable = false, length = 100)
    private String eventType;

    /**
     * Event payload (full object data + metadata)
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "payload", columnDefinition = "jsonb", nullable = false)
    private Map<String, Object> payload;

    /**
     * Event status: PENDING, PUBLISHED, FAILED
     */
    @Column(name = "status", nullable = false, length = 50)
    @Builder.Default
    private String status = "PENDING";

    /**
     * Kafka topic name
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
     * Retry count
     */
    @Column(name = "retry_count", nullable = false)
    @Builder.Default
    private Integer retryCount = 0;

    /**
     * Maximum retries allowed
     */
    @Column(name = "max_retries", nullable = false)
    @Builder.Default
    private Integer maxRetries = 3;

    /**
     * Last error message
     */
    @Column(name = "error_message", length = 2000)
    private String errorMessage;

    /**
     * Last error stack trace
     */
    @Column(name = "error_stack_trace", columnDefinition = "TEXT")
    private String errorStackTrace;

    /**
     * When the event was published
     */
    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    /**
     * When the last retry was attempted
     */
    @Column(name = "last_retry_at")
    private LocalDateTime lastRetryAt;

    /**
     * Next scheduled retry time
     */
    @Column(name = "next_retry_at")
    private LocalDateTime nextRetryAt;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // === Status Constants ===
    
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PUBLISHED = "PUBLISHED";
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_DLQ = "DEAD_LETTER_QUEUE";

    // === Event Type Constants ===
    
    public static final String EVENT_OBJECT_CREATED = "object.created";
    public static final String EVENT_OBJECT_UPDATED = "object.updated";
    public static final String EVENT_OBJECT_DELETED = "object.deleted";
    public static final String EVENT_OBJECT_RESTORED = "object.restored";
    public static final String EVENT_RELATIONSHIP_CREATED = "relationship.created";
    public static final String EVENT_RELATIONSHIP_DELETED = "relationship.deleted";

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
     * Mark as failed
     */
    public void markAsFailed(String errorMessage, String stackTrace) {
        this.status = STATUS_FAILED;
        this.errorMessage = errorMessage;
        this.errorStackTrace = stackTrace;
        this.lastRetryAt = LocalDateTime.now();
        this.retryCount++;
        
        // Move to DLQ if max retries exceeded
        if (this.retryCount >= this.maxRetries) {
            this.status = STATUS_DLQ;
        } else {
            // Calculate exponential backoff
            long backoffMinutes = (long) Math.pow(2, this.retryCount);
            this.nextRetryAt = LocalDateTime.now().plusMinutes(backoffMinutes);
        }
    }

    /**
     * Check if event can be retried
     */
    public boolean canRetry() {
        return STATUS_FAILED.equals(status) && 
               retryCount < maxRetries &&
               (nextRetryAt == null || LocalDateTime.now().isAfter(nextRetryAt));
    }

    /**
     * Check if event is in DLQ
     */
    public boolean isInDeadLetterQueue() {
        return STATUS_DLQ.equals(status);
    }

    @Override
    public String toString() {
        return "ObjectEvent{" +
                "id=" + id +
                ", objectId=" + objectId +
                ", eventType='" + eventType + '\'' +
                ", status='" + status + '\'' +
                ", retryCount=" + retryCount +
                ", createdAt=" + createdAt +
                '}';
    }
}
