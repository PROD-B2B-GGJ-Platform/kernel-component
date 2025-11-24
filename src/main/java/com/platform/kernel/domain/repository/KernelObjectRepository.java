package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.KernelObject;
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
 * Repository for KernelObject entity
 * 
 * Provides:
 * - Standard CRUD operations
 * - Multi-tenant filtering
 * - Complex queries
 * - JSONB path queries
 */
@Repository
public interface KernelObjectRepository extends JpaRepository<KernelObject, UUID> {

    // === Basic Queries ===

    /**
     * Find object by ID and tenant (multi-tenant safe)
     */
    Optional<KernelObject> findByIdAndTenantId(UUID id, UUID tenantId);

    /**
     * Find object by code (tenant-scoped)
     */
    Optional<KernelObject> findByTenantIdAndObjectTypeCodeAndObjectCode(
            UUID tenantId, String objectTypeCode, String objectCode);

    /**
     * Find all objects by type
     */
    Page<KernelObject> findByTenantIdAndObjectTypeCode(
            UUID tenantId, String objectTypeCode, Pageable pageable);

    /**
     * Find all objects by status
     */
    Page<KernelObject> findByTenantIdAndStatus(
            UUID tenantId, String status, Pageable pageable);

    /**
     * Find all non-deleted objects
     */
    Page<KernelObject> findByTenantIdAndIsDeleted(
            UUID tenantId, Boolean isDeleted, Pageable pageable);

    /**
     * Find all objects by type and status
     */
    Page<KernelObject> findByTenantIdAndObjectTypeCodeAndStatus(
            UUID tenantId, String objectTypeCode, String status, Pageable pageable);

    // === Date Range Queries ===

    /**
     * Find objects created within date range
     */
    Page<KernelObject> findByTenantIdAndCreatedAtBetween(
            UUID tenantId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    /**
     * Find objects modified within date range
     */
    Page<KernelObject> findByTenantIdAndModifiedAtBetween(
            UUID tenantId, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    // === Search Queries ===

    /**
     * Search objects by code pattern
     */
    @Query("SELECT o FROM KernelObject o WHERE o.tenantId = :tenantId " +
           "AND o.objectCode LIKE %:searchTerm% AND o.isDeleted = false")
    Page<KernelObject> searchByCode(@Param("tenantId") UUID tenantId,
                                      @Param("searchTerm") String searchTerm,
                                      Pageable pageable);

    // === Count Queries ===

    /**
     * Count objects by type
     */
    long countByTenantIdAndObjectTypeCode(UUID tenantId, String objectTypeCode);

    /**
     * Count objects by status
     */
    long countByTenantIdAndStatus(UUID tenantId, String status);

    /**
     * Count non-deleted objects
     */
    long countByTenantIdAndIsDeleted(UUID tenantId, Boolean isDeleted);

    // === Bulk Operations ===

    /**
     * Find multiple objects by IDs
     */
    List<KernelObject> findByIdInAndTenantId(List<UUID> ids, UUID tenantId);

    /**
     * Delete all objects by IDs (batch delete)
     */
    void deleteByIdInAndTenantId(List<UUID> ids, UUID tenantId);

    // === Advanced Queries ===

    /**
     * Find recently modified objects
     */
    @Query("SELECT o FROM KernelObject o WHERE o.tenantId = :tenantId " +
           "AND o.modifiedAt >= :since ORDER BY o.modifiedAt DESC")
    List<KernelObject> findRecentlyModified(@Param("tenantId") UUID tenantId,
                                             @Param("since") LocalDateTime since,
                                             Pageable pageable);

    /**
     * Find objects by creator
     */
    Page<KernelObject> findByTenantIdAndCreatedBy(
            UUID tenantId, String createdBy, Pageable pageable);

    /**
     * Find objects by modifier
     */
    Page<KernelObject> findByTenantIdAndModifiedBy(
            UUID tenantId, String modifiedBy, Pageable pageable);

    // === Statistics Queries ===

    /**
     * Get object count by type
     */
    @Query("SELECT o.objectTypeCode, COUNT(o) FROM KernelObject o " +
           "WHERE o.tenantId = :tenantId AND o.isDeleted = false " +
           "GROUP BY o.objectTypeCode")
    List<Object[]> getObjectCountByType(@Param("tenantId") UUID tenantId);

    /**
     * Get object count by status
     */
    @Query("SELECT o.status, COUNT(o) FROM KernelObject o " +
           "WHERE o.tenantId = :tenantId AND o.isDeleted = false " +
           "GROUP BY o.status")
    List<Object[]> getObjectCountByStatus(@Param("tenantId") UUID tenantId);

    // === Cleanup Queries ===

    /**
     * Find soft-deleted objects older than specified date (for purge)
     */
    @Query("SELECT o FROM KernelObject o WHERE o.tenantId = :tenantId " +
           "AND o.isDeleted = true AND o.deletedAt < :olderThan")
    List<KernelObject> findDeletedObjectsOlderThan(
            @Param("tenantId") UUID tenantId,
            @Param("olderThan") LocalDateTime olderThan);
}
