package com.platform.kernel.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Metadata Cache Entity
 * 
 * Caches metadata from admin-tool-component for autonomous operation.
 * 
 * Purpose:
 * - Kernel can validate objects without calling admin-tool
 * - Continues working if admin-tool is temporarily down
 * - Eventual consistency via event-driven sync
 * - Reduces network calls and latency
 * 
 * Sync Strategy:
 * - Listens to metadata change events from admin-tool
 * - Periodically refreshes stale cache
 * - Fallback to basic validation if cache is stale
 */
@Entity
@Table(name = "ggj_metadata_cache",
       indexes = {
           @Index(name = "idx_meta_object_type", columnList = "object_type_code", unique = true),
           @Index(name = "idx_meta_synced", columnList = "synced_at"),
           @Index(name = "idx_meta_stale", columnList = "is_stale")
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class MetadataCache {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Object Type Code (e.g., "REQUISITION", "CANDIDATE")
     */
    @Column(name = "object_type_code", nullable = false, unique = true, length = 100)
    private String objectTypeCode;

    /**
     * Object Type Name (human-readable)
     */
    @Column(name = "object_type_name", nullable = false, length = 200)
    private String objectTypeName;

    /**
     * Complete metadata from admin-tool
     * Includes: attributes, groups, validation rules, etc.
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb", nullable = false)
    private Map<String, Object> metadata;

    /**
     * Attribute definitions for this object type
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "attribute_definitions", columnDefinition = "jsonb")
    private Map<String, Object> attributeDefinitions;

    /**
     * Validation rules
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "validation_rules", columnDefinition = "jsonb")
    private Map<String, Object> validationRules;

    /**
     * When this metadata was last synced from admin-tool
     */
    @Column(name = "synced_at", nullable = false)
    private LocalDateTime syncedAt;

    /**
     * Whether this cache is stale (needs refresh)
     */
    @Column(name = "is_stale", nullable = false)
    @Builder.Default
    private Boolean isStale = false;

    /**
     * TTL in minutes (how long before cache is considered stale)
     */
    @Column(name = "ttl_minutes", nullable = false)
    @Builder.Default
    private Integer ttlMinutes = 60; // 1 hour default

    /**
     * Number of times this cache has been used
     */
    @Column(name = "usage_count", nullable = false)
    @Builder.Default
    private Long usageCount = 0L;

    /**
     * Last time this cache was accessed
     */
    @Column(name = "last_accessed_at")
    private LocalDateTime lastAccessedAt;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "modified_at")
    private LocalDateTime modifiedAt;

    // === Helper Methods ===

    /**
     * Check if cache is expired
     */
    public boolean isExpired() {
        if (syncedAt == null) return true;
        LocalDateTime expiryTime = syncedAt.plusMinutes(ttlMinutes);
        return LocalDateTime.now().isAfter(expiryTime);
    }

    /**
     * Mark as stale
     */
    public void markAsStale() {
        this.isStale = true;
    }

    /**
     * Refresh cache with new metadata
     */
    public void refresh(Map<String, Object> newMetadata) {
        this.metadata = newMetadata;
        this.syncedAt = LocalDateTime.now();
        this.isStale = false;
    }

    /**
     * Record cache access
     */
    public void recordAccess() {
        this.usageCount++;
        this.lastAccessedAt = LocalDateTime.now();
    }

    /**
     * Check if cache is valid for use
     */
    public boolean isValid() {
        return !isStale && !isExpired();
    }

    @Override
    public String toString() {
        return "MetadataCache{" +
                "id=" + id +
                ", objectTypeCode='" + objectTypeCode + '\'' +
                ", objectTypeName='" + objectTypeName + '\'' +
                ", syncedAt=" + syncedAt +
                ", isStale=" + isStale +
                ", usageCount=" + usageCount +
                '}';
    }
}

