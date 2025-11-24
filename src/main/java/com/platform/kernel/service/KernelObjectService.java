package com.platform.kernel.service;

import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.repository.KernelObjectRepository;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for KernelObject operations
 * 
 * Features:
 * - CRUD operations with caching
 * - Version control integration
 * - Event publishing
 * - Circuit breaker for resilience
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class KernelObjectService {

    private final KernelObjectRepository objectRepository;
    private final ObjectVersionService versionService;
    private final EventPublisherService eventPublisher;

    /**
     * Create new object
     */
    @Transactional
    @Retry(name = "database")
    public KernelObject createObject(UUID tenantId, String objectTypeCode, String objectCode, 
                                      Map<String, Object> data, String createdBy) {
        log.info("Creating object: tenant={}, type={}, code={}", tenantId, objectTypeCode, objectCode);
        
        // Create object
        KernelObject object = KernelObject.builder()
            .tenantId(tenantId)
            .objectTypeCode(objectTypeCode)
            .objectCode(objectCode)
            .data(data)
            .status("ACTIVE")
            .version(1)
            .isDeleted(false)
            .build();
        
        // Save to database
        KernelObject saved = objectRepository.save(object);
        
        // Create initial version
        versionService.createVersion(saved, "CREATE", null, data, createdBy, null, null);
        
        // Publish event
        eventPublisher.publishObjectCreated(saved);
        
        log.info("Object created successfully: id={}", saved.getId());
        return saved;
    }

    /**
     * Get object by ID (with caching)
     */
    @Cacheable(value = "objects", key = "#tenantId + ':' + #objectId")
    @CircuitBreaker(name = "redis", fallbackMethod = "getObjectByIdFallback")
    public Optional<KernelObject> getObjectById(UUID tenantId, UUID objectId) {
        log.debug("Getting object: tenant={}, id={}", tenantId, objectId);
        return objectRepository.findByIdAndTenantId(objectId, tenantId);
    }

    /**
     * Fallback for getObjectById when Redis is down
     */
    public Optional<KernelObject> getObjectByIdFallback(UUID tenantId, UUID objectId, Exception ex) {
        log.warn("Redis fallback for getObjectById: tenant={}, id={}", tenantId, objectId, ex);
        return objectRepository.findByIdAndTenantId(objectId, tenantId);
    }

    /**
     * Get object by code
     */
    @Cacheable(value = "objects", key = "#tenantId + ':' + #objectTypeCode + ':' + #objectCode")
    public Optional<KernelObject> getObjectByCode(UUID tenantId, String objectTypeCode, String objectCode) {
        return objectRepository.findByTenantIdAndObjectTypeCodeAndObjectCode(
            tenantId, objectTypeCode, objectCode);
    }

    /**
     * List objects by type (paginated)
     */
    public Page<KernelObject> listObjectsByType(UUID tenantId, String objectTypeCode, Pageable pageable) {
        return objectRepository.findByTenantIdAndObjectTypeCode(tenantId, objectTypeCode, pageable);
    }

    /**
     * Update object
     */
    @Transactional
    @CacheEvict(value = "objects", key = "#tenantId + ':' + #objectId")
    @Retry(name = "database")
    public KernelObject updateObject(UUID tenantId, UUID objectId, Map<String, Object> newData, 
                                      String modifiedBy) {
        log.info("Updating object: tenant={}, id={}", tenantId, objectId);
        
        // Get existing object
        KernelObject object = objectRepository.findByIdAndTenantId(objectId, tenantId)
            .orElseThrow(() -> new RuntimeException("Object not found: " + objectId));
        
        // Store previous data
        Map<String, Object> previousData = object.getData();
        
        // Update object
        object.setData(newData);
        object.incrementVersion();
        
        // Save to database
        KernelObject updated = objectRepository.save(object);
        
        // Create version
        versionService.createVersion(updated, "UPDATE", previousData, newData, modifiedBy, null, null);
        
        // Publish event
        eventPublisher.publishObjectUpdated(updated);
        
        log.info("Object updated successfully: id={}, version={}", updated.getId(), updated.getVersion());
        return updated;
    }

    /**
     * Soft delete object
     */
    @Transactional
    @CacheEvict(value = "objects", key = "#tenantId + ':' + #objectId")
    @Retry(name = "database")
    public void deleteObject(UUID tenantId, UUID objectId, String deletedBy) {
        log.info("Deleting object: tenant={}, id={}", tenantId, objectId);
        
        // Get object
        KernelObject object = objectRepository.findByIdAndTenantId(objectId, tenantId)
            .orElseThrow(() -> new RuntimeException("Object not found: " + objectId));
        
        // Mark as deleted
        Map<String, Object> previousData = object.getData();
        object.markAsDeleted(deletedBy);
        
        // Save to database
        KernelObject deleted = objectRepository.save(object);
        
        // Create version
        versionService.createVersion(deleted, "DELETE", previousData, null, deletedBy, null, null);
        
        // Publish event
        eventPublisher.publishObjectDeleted(deleted);
        
        log.info("Object deleted successfully: id={}", deleted.getId());
    }

    /**
     * Restore deleted object
     */
    @Transactional
    @CacheEvict(value = "objects", key = "#tenantId + ':' + #objectId")
    public KernelObject restoreObject(UUID tenantId, UUID objectId, String restoredBy) {
        log.info("Restoring object: tenant={}, id={}", tenantId, objectId);
        
        // Get object
        KernelObject object = objectRepository.findByIdAndTenantId(objectId, tenantId)
            .orElseThrow(() -> new RuntimeException("Object not found: " + objectId));
        
        if (!object.getIsDeleted()) {
            throw new RuntimeException("Object is not deleted");
        }
        
        // Restore object
        object.restore();
        
        // Save to database
        KernelObject restored = objectRepository.save(object);
        
        // Create version
        versionService.createVersion(restored, "RESTORE", null, restored.getData(), restoredBy, null, null);
        
        // Publish event
        eventPublisher.publishObjectRestored(restored);
        
        log.info("Object restored successfully: id={}", restored.getId());
        return restored;
    }

    /**
     * Count objects by type
     */
    public long countObjectsByType(UUID tenantId, String objectTypeCode) {
        return objectRepository.countByTenantIdAndObjectTypeCode(tenantId, objectTypeCode);
    }

    /**
     * Search objects by code pattern
     */
    public Page<KernelObject> searchObjects(UUID tenantId, String searchTerm, Pageable pageable) {
        return objectRepository.searchByCode(tenantId, searchTerm, pageable);
    }

    /**
     * Get recently modified objects
     */
    public List<KernelObject> getRecentlyModified(UUID tenantId, LocalDateTime since, int limit) {
        return objectRepository.findRecentlyModified(tenantId, since, Pageable.ofSize(limit));
    }
}

