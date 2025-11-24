package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.ObjectVersion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ObjectVersion entity
 */
@Repository
public interface ObjectVersionRepository extends JpaRepository<ObjectVersion, UUID> {

    /**
     * Find all versions for an object
     */
    List<ObjectVersion> findByObjectIdOrderByVersionNumberDesc(UUID objectId);

    /**
     * Find specific version of an object
     */
    Optional<ObjectVersion> findByObjectIdAndVersionNumber(UUID objectId, Integer versionNumber);

    /**
     * Find latest version of an object
     */
    @Query("SELECT v FROM ObjectVersion v WHERE v.objectId = :objectId " +
           "ORDER BY v.versionNumber DESC LIMIT 1")
    Optional<ObjectVersion> findLatestVersion(@Param("objectId") UUID objectId);

    /**
     * Find versions by change type
     */
    List<ObjectVersion> findByObjectIdAndChangeType(UUID objectId, String changeType);

    /**
     * Find versions within date range
     */
    Page<ObjectVersion> findByObjectIdAndCreatedAtBetween(
            UUID objectId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    /**
     * Find versions by user
     */
    List<ObjectVersion> findByObjectIdAndChangedBy(UUID objectId, String changedBy);

    /**
     * Count versions for an object
     */
    long countByObjectId(UUID objectId);

    /**
     * Find object version at specific time
     */
    @Query("SELECT v FROM ObjectVersion v WHERE v.objectId = :objectId " +
           "AND v.createdAt <= :timestamp ORDER BY v.createdAt DESC LIMIT 1")
    Optional<ObjectVersion> findVersionAtTime(@Param("objectId") UUID objectId,
                                                @Param("timestamp") LocalDateTime timestamp);

    /**
     * Find all versions created by a specific user
     */
    Page<ObjectVersion> findByChangedBy(String changedBy, Pageable pageable);
}
