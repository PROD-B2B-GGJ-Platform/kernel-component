package com.platform.kernel.domain.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.repository.KernelObjectRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ObjectService - Core business logic for KernelObject
 * 
 * Responsibilities:
 * - CRUD operations with validation
 * - Version management coordination
 * - Event publishing coordination
 * - Cache invalidation coordination
 * 
 * @author Platform Team
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class ObjectService {

    private final KernelObjectRepository repository;
    private final VersionService versionService;
    private final EventService eventService;
    private final CacheService cacheService;
    private final ObjectMapper objectMapper;

    /**
     * Create new object
     */
    @Transactional
    public KernelObject createObject(
        UUID tenantId,
        String objectTypeCode,
        String objectCode,
        String objectName,
        JsonNode data,
        String currentUser
    ) {
        log.info("Creating object: tenant={}, type={}, code={}", 
            tenantId, objectTypeCode, objectCode);

        // Check if object code already exists
        if (repository.existsByTenantIdAndObjectTypeCodeAndObjectCodeAndIsDeletedFalse(
            tenantId, objectTypeCode, objectCode)) {
            throw new IllegalArgumentException(
                String.format("Object with code '%s' already exists", objectCode)
            );
        }

        // Create object
        KernelObject object = KernelObject.builder()
            .tenantId(tenantId)
            .objectTypeCode(objectTypeCode)
            .objectCode(objectCode)
            .objectName(objectName)
            .data(data)
            .version(1)
            .status("ACTIVE")
            .isDeleted(false)
            .build();

        object = repository.save(object);
        log.info("Object created: id={}", object.getId());

        // Create version history
        versionService.createVersion(object, "CREATE", "Object created", null);

        // Publish event
        eventService.publishObjectCreatedEvent(object);

        // Cache the object
        cacheService.cacheObject(object);

        return object;
    }

    /**
     * Update existing object
     */
    @Transactional
    public KernelObject updateObject(
        UUID objectId,
        UUID tenantId,
        String objectName,
        JsonNode data,
        String changeDescription
    ) {
        log.info("Updating object: id={}, tenant={}", objectId, tenantId);

        // Find object
        KernelObject object = repository.findById(objectId)
            .filter(o -> o.getTenantId().equals(tenantId) && !o.getIsDeleted())
            .orElseThrow(() -> new IllegalArgumentException(
                String.format("Object not found: id=%s", objectId)
            ));

        // Store old data for version diff
        JsonNode oldData = object.getData();

        // Update object
        object.setObjectName(objectName);
        object.setData(data);
        object.setVersion(object.getVersion() + 1);

        object = repository.save(object);
        log.info("Object updated: id={}, new version={}", object.getId(), object.getVersion());

        // Create version history
        versionService.createVersion(object, "UPDATE", changeDescription, oldData);

        // Publish event
        eventService.publishObjectUpdatedEvent(object);

        // Invalidate and update cache
        cacheService.invalidateObject(objectId);
        cacheService.cacheObject(object);

        return object;
    }

    /**
     * Soft delete object
     */
    @Transactional
    public void deleteObject(UUID objectId, UUID tenantId, String reason) {
        log.info("Deleting object: id={}, tenant={}", objectId, tenantId);

        KernelObject object = repository.findById(objectId)
            .filter(o -> o.getTenantId().equals(tenantId) && !o.getIsDeleted())
            .orElseThrow(() -> new IllegalArgumentException(
                String.format("Object not found: id=%s", objectId)
            ));

        // Soft delete
        object.setIsDeleted(true);
        object.setDeletedAt(LocalDateTime.now());
        object.setVersion(object.getVersion() + 1);

        repository.save(object);
        log.info("Object deleted: id={}", objectId);

        // Create version history
        versionService.createVersion(object, "DELETE", reason, null);

        // Publish event
        eventService.publishObjectDeletedEvent(object);

        // Invalidate cache
        cacheService.invalidateObject(objectId);
    }

    /**
     * Get object by ID
     */
    @Transactional(readOnly = true)
    public Optional<KernelObject> getObject(UUID objectId, UUID tenantId) {
        // Try cache first
        Optional<KernelObject> cached = cacheService.getCachedObject(objectId);
        if (cached.isPresent()) {
            log.debug("Object found in cache: id={}", objectId);
            return cached;
        }

        // Load from database
        Optional<KernelObject> object = repository.findById(objectId)
            .filter(o -> o.getTenantId().equals(tenantId) && !o.getIsDeleted());

        // Cache if found
        object.ifPresent(cacheService::cacheObject);

        return object;
    }

    /**
     * Get object by code
     */
    @Transactional(readOnly = true)
    public Optional<KernelObject> getObjectByCode(
        UUID tenantId,
        String objectTypeCode,
        String objectCode
    ) {
        return repository.findByTenantIdAndObjectTypeCodeAndObjectCodeAndIsDeletedFalse(
            tenantId, objectTypeCode, objectCode
        );
    }

    /**
     * List objects by type
     */
    @Transactional(readOnly = true)
    public Page<KernelObject> listObjects(
        UUID tenantId,
        String objectTypeCode,
        Pageable pageable
    ) {
        return repository.findByTenantIdAndObjectTypeCodeAndIsDeletedFalse(
            tenantId, objectTypeCode, pageable
        );
    }

    /**
     * Search objects by name
     */
    @Transactional(readOnly = true)
    public Page<KernelObject> searchObjects(
        UUID tenantId,
        String objectTypeCode,
        String searchTerm,
        Pageable pageable
    ) {
        return repository.searchByName(tenantId, objectTypeCode, searchTerm, pageable);
    }

    /**
     * List objects by status
     */
    @Transactional(readOnly = true)
    public Page<KernelObject> listObjectsByStatus(
        UUID tenantId,
        String objectTypeCode,
        String status,
        Pageable pageable
    ) {
        return repository.findByTenantIdAndObjectTypeCodeAndStatusAndIsDeletedFalse(
            tenantId, objectTypeCode, status, pageable
        );
    }

    /**
     * Count objects by type
     */
    @Transactional(readOnly = true)
    public Long countObjects(UUID tenantId, String objectTypeCode) {
        return repository.countByTenantIdAndObjectTypeCodeAndIsDeletedFalse(
            tenantId, objectTypeCode
        );
    }

    /**
     * Bulk read objects
     */
    @Transactional(readOnly = true)
    public List<KernelObject> getObjects(UUID tenantId, List<UUID> objectIds) {
        return repository.findByTenantIdAndIdIn(tenantId, objectIds);
    }

    /**
     * Query objects by JSON attribute
     */
    @Transactional(readOnly = true)
    public List<KernelObject> findByAttribute(
        UUID tenantId,
        String objectTypeCode,
        String attributeKey,
        String attributeValue
    ) {
        return repository.findByJsonAttribute(
            tenantId, objectTypeCode, attributeKey, attributeValue
        );
    }

    /**
     * Change object status
     */
    @Transactional
    public KernelObject changeStatus(
        UUID objectId,
        UUID tenantId,
        String newStatus,
        String reason
    ) {
        KernelObject object = getObject(objectId, tenantId)
            .orElseThrow(() -> new IllegalArgumentException(
                String.format("Object not found: id=%s", objectId)
            ));

        String oldStatus = object.getStatus();
        object.setStatus(newStatus);
        object.setVersion(object.getVersion() + 1);

        object = repository.save(object);

        // Create version history
        versionService.createVersion(
            object, 
            "STATUS_CHANGE", 
            String.format("Status changed from %s to %s: %s", oldStatus, newStatus, reason),
            null
        );

        // Publish event
        eventService.publishObjectUpdatedEvent(object);

        // Update cache
        cacheService.invalidateObject(objectId);
        cacheService.cacheObject(object);

        return object;
    }
}

