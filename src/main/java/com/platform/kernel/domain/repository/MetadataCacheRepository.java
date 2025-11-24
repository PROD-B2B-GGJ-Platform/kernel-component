package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.MetadataCache;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for MetadataCache entity
 */
@Repository
public interface MetadataCacheRepository extends JpaRepository<MetadataCache, UUID> {

    /**
     * Find metadata by object type code
     */
    Optional<MetadataCache> findByObjectTypeCode(String objectTypeCode);

    /**
     * Find all stale cache entries
     */
    List<MetadataCache> findByIsStaleTrue();

    /**
     * Find cache entries that need refresh (expired)
     */
    @Query("SELECT m FROM MetadataCache m WHERE " +
           "m.syncedAt < :expiryTime OR m.isStale = true")
    List<MetadataCache> findExpiredCache(@Param("expiryTime") LocalDateTime expiryTime);

    /**
     * Find most frequently accessed cache entries
     */
    List<MetadataCache> findTop10ByOrderByUsageCountDesc();

    /**
     * Find recently synced cache entries
     */
    List<MetadataCache> findBySyncedAtAfter(LocalDateTime since);

    /**
     * Check if metadata exists for object type
     */
    boolean existsByObjectTypeCode(String objectTypeCode);

    /**
     * Count stale cache entries
     */
    long countByIsStaleTrue();
}

