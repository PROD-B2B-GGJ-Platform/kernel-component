package com.platform.kernel.api.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.platform.kernel.api.dto.CreateObjectRequest;
import com.platform.kernel.api.dto.ObjectResponse;
import com.platform.kernel.api.dto.UpdateObjectRequest;
import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.service.ObjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Kernel Object REST API
 * 
 * Endpoints:
 * - POST   /api/v1/kernel/objects              - Create object
 * - GET    /api/v1/kernel/objects/{id}         - Get object
 * - PUT    /api/v1/kernel/objects/{id}         - Update object
 * - DELETE /api/v1/kernel/objects/{id}         - Delete object
 * - GET    /api/v1/kernel/objects              - List objects
 * - GET    /api/v1/kernel/objects/search       - Search objects
 * 
 * @author Platform Team
 */
@RestController
@RequestMapping("/api/v1/kernel/objects")
@Tag(name = "Kernel Objects", description = "Core object storage API")
@Slf4j
@RequiredArgsConstructor
public class KernelObjectController {

    private final ObjectService objectService;

    /**
     * Create new object
     */
    @PostMapping
    @Operation(summary = "Create new object")
    public ResponseEntity<ObjectResponse> createObject(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestHeader(value = "X-User-Id", required = false) String userId,
        @Valid @RequestBody CreateObjectRequest request
    ) {
        log.info("Creating object: tenant={}, type={}", tenantId, request.getObjectTypeCode());

        KernelObject object = objectService.createObject(
            tenantId,
            request.getObjectTypeCode(),
            request.getObjectCode(),
            request.getObjectName(),
            request.getData(),
            userId
        );

        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ObjectResponse.from(object));
    }

    /**
     * Get object by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get object by ID")
    public ResponseEntity<ObjectResponse> getObject(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @PathVariable UUID id
    ) {
        log.debug("Getting object: id={}, tenant={}", id, tenantId);

        return objectService.getObject(id, tenantId)
            .map(object -> ResponseEntity.ok(ObjectResponse.from(object)))
            .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Update object
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update object")
    public ResponseEntity<ObjectResponse> updateObject(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @PathVariable UUID id,
        @Valid @RequestBody UpdateObjectRequest request
    ) {
        log.info("Updating object: id={}, tenant={}", id, tenantId);

        KernelObject object = objectService.updateObject(
            id,
            tenantId,
            request.getObjectName(),
            request.getData(),
            request.getChangeDescription()
        );

        return ResponseEntity.ok(ObjectResponse.from(object));
    }

    /**
     * Delete object (soft delete)
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete object")
    public ResponseEntity<Void> deleteObject(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @PathVariable UUID id,
        @RequestParam(required = false) String reason
    ) {
        log.info("Deleting object: id={}, tenant={}", id, tenantId);

        objectService.deleteObject(id, tenantId, reason);
        return ResponseEntity.noContent().build();
    }

    /**
     * List objects by type
     */
    @GetMapping
    @Operation(summary = "List objects")
    public ResponseEntity<Page<ObjectResponse>> listObjects(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestParam String objectTypeCode,
        @RequestParam(required = false) String status,
        Pageable pageable
    ) {
        log.debug("Listing objects: tenant={}, type={}, status={}", 
            tenantId, objectTypeCode, status);

        Page<KernelObject> objects = (status != null)
            ? objectService.listObjectsByStatus(tenantId, objectTypeCode, status, pageable)
            : objectService.listObjects(tenantId, objectTypeCode, pageable);

        Page<ObjectResponse> response = objects.map(ObjectResponse::from);
        return ResponseEntity.ok(response);
    }

    /**
     * Search objects by name
     */
    @GetMapping("/search")
    @Operation(summary = "Search objects")
    public ResponseEntity<Page<ObjectResponse>> searchObjects(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestParam String objectTypeCode,
        @RequestParam String q,
        Pageable pageable
    ) {
        log.debug("Searching objects: tenant={}, type={}, query={}", 
            tenantId, objectTypeCode, q);

        Page<KernelObject> objects = objectService.searchObjects(
            tenantId, objectTypeCode, q, pageable
        );

        Page<ObjectResponse> response = objects.map(ObjectResponse::from);
        return ResponseEntity.ok(response);
    }

    /**
     * Get object by code
     */
    @GetMapping("/by-code")
    @Operation(summary = "Get object by code")
    public ResponseEntity<ObjectResponse> getObjectByCode(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestParam String objectTypeCode,
        @RequestParam String objectCode
    ) {
        log.debug("Getting object by code: tenant={}, type={}, code={}", 
            tenantId, objectTypeCode, objectCode);

        return objectService.getObjectByCode(tenantId, objectTypeCode, objectCode)
            .map(object -> ResponseEntity.ok(ObjectResponse.from(object)))
            .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Count objects
     */
    @GetMapping("/count")
    @Operation(summary = "Count objects")
    public ResponseEntity<Long> countObjects(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestParam String objectTypeCode
    ) {
        Long count = objectService.countObjects(tenantId, objectTypeCode);
        return ResponseEntity.ok(count);
    }

    /**
     * Change object status
     */
    @PatchMapping("/{id}/status")
    @Operation(summary = "Change object status")
    public ResponseEntity<ObjectResponse> changeStatus(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @PathVariable UUID id,
        @RequestParam String status,
        @RequestParam(required = false) String reason
    ) {
        log.info("Changing object status: id={}, status={}", id, status);

        KernelObject object = objectService.changeStatus(id, tenantId, status, reason);
        return ResponseEntity.ok(ObjectResponse.from(object));
    }

    /**
     * Bulk read objects
     */
    @PostMapping("/bulk-read")
    @Operation(summary = "Bulk read objects")
    public ResponseEntity<List<ObjectResponse>> bulkRead(
        @RequestHeader("X-Tenant-Id") UUID tenantId,
        @RequestBody List<UUID> objectIds
    ) {
        log.debug("Bulk reading {} objects", objectIds.size());

        List<KernelObject> objects = objectService.getObjects(tenantId, objectIds);
        List<ObjectResponse> response = objects.stream()
            .map(ObjectResponse::from)
            .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }
}

