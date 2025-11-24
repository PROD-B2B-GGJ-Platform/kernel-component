package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.ObjectRelationship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ObjectRelationship entity
 */
@Repository
public interface ObjectRelationshipRepository extends JpaRepository<ObjectRelationship, UUID> {

    /**
     * Find all relationships for an object (as source)
     */
    List<ObjectRelationship> findBySourceObjectId(UUID sourceObjectId);

    /**
     * Find all relationships for an object (as target)
     */
    List<ObjectRelationship> findByTargetObjectId(UUID targetObjectId);

    /**
     * Find all relationships for an object (either source or target)
     */
    @Query("SELECT r FROM ObjectRelationship r WHERE " +
           "r.sourceObjectId = :objectId OR r.targetObjectId = :objectId")
    List<ObjectRelationship> findByObjectId(@Param("objectId") UUID objectId);

    /**
     * Find relationships by type
     */
    List<ObjectRelationship> findBySourceObjectIdAndRelationshipType(
            UUID sourceObjectId, String relationshipType);

    /**
     * Find specific relationship between two objects
     */
    Optional<ObjectRelationship> findBySourceObjectIdAndTargetObjectIdAndRelationshipType(
            UUID sourceObjectId, UUID targetObjectId, String relationshipType);

    /**
     * Find all related objects (as targets) for a specific relationship type
     */
    @Query("SELECT r.targetObjectId FROM ObjectRelationship r WHERE " +
           "r.sourceObjectId = :sourceObjectId AND r.relationshipType = :relationshipType " +
           "AND r.isActive = true")
    List<UUID> findRelatedObjectIds(@Param("sourceObjectId") UUID sourceObjectId,
                                      @Param("relationshipType") String relationshipType);

    /**
     * Check if relationship exists
     */
    boolean existsBySourceObjectIdAndTargetObjectIdAndRelationshipType(
            UUID sourceObjectId, UUID targetObjectId, String relationshipType);

    /**
     * Count relationships for an object
     */
    long countBySourceObjectId(UUID sourceObjectId);

    /**
     * Find bidirectional relationships
     */
    List<ObjectRelationship> findBySourceObjectIdAndIsBidirectional(
            UUID sourceObjectId, Boolean isBidirectional);

    /**
     * Delete all relationships involving an object
     */
    @Query("DELETE FROM ObjectRelationship r WHERE " +
           "r.sourceObjectId = :objectId OR r.targetObjectId = :objectId")
    void deleteByObjectId(@Param("objectId") UUID objectId);
}
