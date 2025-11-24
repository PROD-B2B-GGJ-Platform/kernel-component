package com.platform.kernel.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Universal Object Storage Entity
 * 
 * Stores any type of object with dynamic schema using JSONB.
 * Examples: Requisitions, Candidates, Interviews, Offers, etc.
 * 
 * Key Features:
 * - Multi-tenant isolation (tenant_id)
 * - Dynamic schema (JSONB data field)
 * - Soft delete support
 * - Version tracking
 * - Full audit trail
 */
@Entity
@Table(name = "ggj_kernel_objects", 
       indexes = {
           @Index(name = "idx_kernel_obj_tenant_type", columnList = "tenant_id, object_type_code"),
           @Index(name = "idx_kernel_obj_tenant_code", columnList = "tenant_id, object_code"),
           @Index(name = "idx_kernel_obj_status", columnList = "status"),
           @Index(name = "idx_kernel_obj_created", columnList = "created_at"),
           @Index(name = "idx_kernel_obj_deleted", columnList = "is_deleted")
       },
       uniqueConstraints = {
           @UniqueConstraint(name = "uk_kernel_obj_tenant_type_code", 
                           columnNames = {"tenant_id", "object_type_code", "object_code"})
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class KernelObject {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Tenant ID for multi-tenancy isolation
     */
    @Column(name = "tenant_id", nullable = false)
    private UUID tenantId;

    /**
     * Object Type Code - Links to admin-tool metadata
     * Examples: "REQUISITION", "CANDIDATE", "INTERVIEW"
     */
    @Column(name = "object_type_code", nullable = false, length = 100)
    private String objectTypeCode;

    /**
     * Human-readable object code (e.g., "REQ-2025-001")
     */
    @Column(name = "object_code", nullable = false, length = 200)
    private String objectCode;

    /**
     * Dynamic JSON data - stores any structure
     * Uses PostgreSQL JSONB for efficient querying
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "data", columnDefinition = "jsonb", nullable = false)
    private Map<String, Object> data;

    /**
     * Object status (DRAFT, ACTIVE, INACTIVE, ARCHIVED, DELETED)
     */
    @Column(name = "status", nullable = false, length = 50)
    @Builder.Default
    private String status = "ACTIVE";

    /**
     * Current version number
     */
    @Column(name = "version", nullable = false)
    @Builder.Default
    private Integer version = 1;

    /**
     * Soft delete flag
     */
    @Column(name = "is_deleted", nullable = false)
    @Builder.Default
    private Boolean isDeleted = false;

    /**
     * Deletion timestamp
     */
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    /**
     * Who deleted the object
     */
    @Column(name = "deleted_by", length = 255)
    private String deletedBy;

    // === Audit Fields (Spring Data JPA Auditing) ===

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @CreatedBy
    @Column(name = "created_by", nullable = false, updatable = false, length = 255)
    private String createdBy;

    @LastModifiedDate
    @Column(name = "modified_at")
    private LocalDateTime modifiedAt;

    @LastModifiedBy
    @Column(name = "modified_by", length = 255)
    private String modifiedBy;

    /**
     * Metadata for tracking (IP address, user agent, etc.)
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    // === Helper Methods ===

    /**
     * Increment version number
     */
    public void incrementVersion() {
        this.version = (this.version == null ? 1 : this.version + 1);
    }

    /**
     * Mark as deleted (soft delete)
     */
    public void markAsDeleted(String deletedBy) {
        this.isDeleted = true;
        this.deletedAt = LocalDateTime.now();
        this.deletedBy = deletedBy;
        this.status = "DELETED";
    }

    /**
     * Restore deleted object
     */
    public void restore() {
        this.isDeleted = false;
        this.deletedAt = null;
        this.deletedBy = null;
        this.status = "ACTIVE";
    }

    /**
     * Get full object identifier
     */
    public String getFullCode() {
        return objectTypeCode + ":" + objectCode;
    }

    @Override
    public String toString() {
        return "KernelObject{" +
                "id=" + id +
                ", objectTypeCode='" + objectTypeCode + '\'' +
                ", objectCode='" + objectCode + '\'' +
                ", status='" + status + '\'' +
                ", version=" + version +
                ", isDeleted=" + isDeleted +
                '}';
    }
}
