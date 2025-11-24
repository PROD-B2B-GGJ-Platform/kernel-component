package com.platform.kernel.domain.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Object Relationship Entity
 * 
 * Links objects together to form a graph structure.
 * 
 * Examples:
 * - Requisition HAS_APPLICANT Candidate
 * - Candidate HAS_INTERVIEW Interview
 * - Employee REPORTS_TO Employee
 * - Task DEPENDS_ON Task
 * 
 * Supports:
 * - Named relationships
 * - Bidirectional navigation
 * - Cardinality constraints
 * - Relationship metadata
 */
@Entity
@Table(name = "ggj_object_relationships",
       indexes = {
           @Index(name = "idx_rel_source", columnList = "source_object_id"),
           @Index(name = "idx_rel_target", columnList = "target_object_id"),
           @Index(name = "idx_rel_type", columnList = "relationship_type"),
           @Index(name = "idx_rel_source_type", columnList = "source_object_id, relationship_type"),
           @Index(name = "idx_rel_target_type", columnList = "target_object_id, relationship_type")
       },
       uniqueConstraints = {
           @UniqueConstraint(name = "uk_rel_source_target_type",
                           columnNames = {"source_object_id", "target_object_id", "relationship_type"})
       })
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class ObjectRelationship {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * Source object ID
     */
    @Column(name = "source_object_id", nullable = false)
    private UUID sourceObjectId;

    /**
     * Target object ID
     */
    @Column(name = "target_object_id", nullable = false)
    private UUID targetObjectId;

    /**
     * Relationship type name
     * Examples: HAS_APPLICANT, ASSIGNED_TO, REPORTS_TO, DEPENDS_ON, CHILD_OF
     */
    @Column(name = "relationship_type", nullable = false, length = 100)
    private String relationshipType;

    /**
     * Cardinality: ONE_TO_ONE, ONE_TO_MANY, MANY_TO_MANY
     */
    @Column(name = "cardinality", nullable = false, length = 50)
    @Builder.Default
    private String cardinality = "MANY_TO_MANY";

    /**
     * Whether the relationship is bidirectional
     */
    @Column(name = "is_bidirectional", nullable = false)
    @Builder.Default
    private Boolean isBidirectional = true;

    /**
     * Inverse relationship type (for bidirectional relationships)
     * Example: If this is HAS_APPLICANT, inverse might be APPLIED_TO
     */
    @Column(name = "inverse_relationship_type", length = 100)
    private String inverseRelationshipType;

    /**
     * Relationship strength (0.0 to 1.0)
     * Used for weighted graph algorithms
     */
    @Column(name = "strength")
    private Double strength;

    /**
     * Display order (for sorting related objects)
     */
    @Column(name = "display_order")
    private Integer displayOrder;

    /**
     * Additional metadata about the relationship
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    /**
     * Whether the relationship is active
     */
    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @CreatedBy
    @Column(name = "created_by", nullable = false, updatable = false, length = 255)
    private String createdBy;

    // === Relationship Type Constants ===
    
    public static final String REL_HAS_APPLICANT = "HAS_APPLICANT";
    public static final String REL_HAS_INTERVIEW = "HAS_INTERVIEW";
    public static final String REL_ASSIGNED_TO = "ASSIGNED_TO";
    public static final String REL_REPORTS_TO = "REPORTS_TO";
    public static final String REL_DEPENDS_ON = "DEPENDS_ON";
    public static final String REL_CHILD_OF = "CHILD_OF";
    public static final String REL_RELATED_TO = "RELATED_TO";

    // === Cardinality Constants ===
    
    public static final String CARD_ONE_TO_ONE = "ONE_TO_ONE";
    public static final String CARD_ONE_TO_MANY = "ONE_TO_MANY";
    public static final String CARD_MANY_TO_MANY = "MANY_TO_MANY";

    // === Helper Methods ===

    /**
     * Check if relationship involves a specific object
     */
    public boolean involvesObject(UUID objectId) {
        return sourceObjectId.equals(objectId) || targetObjectId.equals(objectId);
    }

    /**
     * Get the other end of the relationship
     */
    public UUID getOtherEnd(UUID objectId) {
        if (sourceObjectId.equals(objectId)) {
            return targetObjectId;
        } else if (targetObjectId.equals(objectId)) {
            return sourceObjectId;
        }
        throw new IllegalArgumentException("Object ID not part of this relationship");
    }

    @Override
    public String toString() {
        return "ObjectRelationship{" +
                "id=" + id +
                ", sourceObjectId=" + sourceObjectId +
                ", targetObjectId=" + targetObjectId +
                ", relationshipType='" + relationshipType + '\'' +
                ", cardinality='" + cardinality + '\'' +
                '}';
    }
}
