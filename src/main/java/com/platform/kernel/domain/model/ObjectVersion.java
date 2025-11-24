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
 * Object Version History Entity
 * 
 * Stores complete snapshot of every object change.
 * Enables:
 * - Full audit trail
 * - Rollback to any version
 * - Time-travel queries
 * - Change comparison
 * - Forensic analysis
 */
@Entity
@Table(name = "ggj_object_versions",
       indexes = {
           @Index(name = "idx_version_object_id", columnList = "object_id"),
           @Index(name = "idx_version_object_version", columnList = "object_id, version_number"),
           @Index(name = "idx_version_created", columnList = "created_at"),
           @Index(name = "idx_version_type", columnList = "change_type"),
           @Index(name = "idx_version_user", columnList = "changed_by")
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class ObjectVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Reference to the object being versioned
     */
    @Column(name = "object_id", nullable = false)
    private UUID objectId;

    /**
     * Version number (sequential)
     */
    @Column(name = "version_number", nullable = false)
    private Integer versionNumber;

    /**
     * Type of change: CREATE, UPDATE, DELETE, RESTORE
     */
    @Column(name = "change_type", nullable = false, length = 50)
    private String changeType;

    /**
     * Snapshot of object data BEFORE the change
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "previous_data", columnDefinition = "jsonb")
    private Map<String, Object> previousData;

    /**
     * Snapshot of object data AFTER the change
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "current_data", columnDefinition = "jsonb", nullable = false)
    private Map<String, Object> currentData;

    /**
     * JSON diff showing what changed
     * Structure: { "added": [...], "modified": {...}, "deleted": [...] }
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "diff", columnDefinition = "jsonb")
    private Map<String, Object> diff;

    /**
     * Who made the change
     */
    @Column(name = "changed_by", nullable = false, length = 255)
    private String changedBy;

    /**
     * IP address of the user
     */
    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    /**
     * User agent string
     */
    @Column(name = "user_agent", length = 500)
    private String userAgent;

    /**
     * Optional reason for the change
     */
    @Column(name = "change_reason", length = 1000)
    private String changeReason;

    /**
     * Additional metadata
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // === Change Type Constants ===
    
    public static final String CHANGE_TYPE_CREATE = "CREATE";
    public static final String CHANGE_TYPE_UPDATE = "UPDATE";
    public static final String CHANGE_TYPE_DELETE = "DELETE";
    public static final String CHANGE_TYPE_RESTORE = "RESTORE";
    public static final String CHANGE_TYPE_STATUS_CHANGE = "STATUS_CHANGE";

    // === Helper Methods ===

    /**
     * Check if this is the initial version
     */
    public boolean isInitialVersion() {
        return versionNumber != null && versionNumber == 1;
    }

    /**
     * Check if this is a delete operation
     */
    public boolean isDeleteOperation() {
        return CHANGE_TYPE_DELETE.equals(changeType);
    }

    /**
     * Check if this is a create operation
     */
    public boolean isCreateOperation() {
        return CHANGE_TYPE_CREATE.equals(changeType);
    }

    @Override
    public String toString() {
        return "ObjectVersion{" +
                "id=" + id +
                ", objectId=" + objectId +
                ", versionNumber=" + versionNumber +
                ", changeType='" + changeType + '\'' +
                ", changedBy='" + changedBy + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
