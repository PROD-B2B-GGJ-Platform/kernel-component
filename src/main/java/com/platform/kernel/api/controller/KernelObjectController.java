package com.platform.kernel.api.controller;

import com.platform.kernel.api.dto.CreateObjectRequest;
import com.platform.kernel.api.dto.ObjectResponse;
import com.platform.kernel.api.dto.UpdateObjectRequest;
import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.service.KernelObjectService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * REST API for KernelObject operations
 */
@RestController
@RequestMapping("/api/v1/kernel/objects")
@RequiredArgsConstructor
@Tag(name = "Kernel Objects", description = "Universal object storage API")
public class KernelObjectController {

    private final KernelObjectService objectService;

    /**
     * Create new object
     */
    @PostMapping
    @Operation(summary = "Create object", description = "Create a new object with dynamic schema")
    public ResponseEntity<ObjectResponse> createObject(@Valid @RequestBody CreateObjectRequest request) {
        KernelObject object = objectService.createObject(
            request.getTenantId(),
            request.getObjectTypeCode(),
            request.getObjectCode(),
            request.getData(),
            "system" // TODO: Extract from SecurityContext
        );
        
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(object));
    }

    /**
     * Get object by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get object", description = "Get object by ID")
    public ResponseEntity<ObjectResponse> getObject(
            @PathVariable UUID id,
            @RequestParam UUID tenantId) {
        return objectService.getObjectById(tenantId, id)
            .map(obj -> ResponseEntity.ok(toResponse(obj)))
            .orElse(ResponseEntity.notFound().build());
    }

    /**
     * List objects by type
     */
    @GetMapping
    @Operation(summary = "List objects", description = "List objects by type (paginated)")
    public ResponseEntity<Page<ObjectResponse>> listObjects(
            @RequestParam UUID tenantId,
            @RequestParam String objectTypeCode,
            Pageable pageable) {
        Page<KernelObject> objects = objectService.listObjectsByType(tenantId, objectTypeCode, pageable);
        return ResponseEntity.ok(objects.map(this::toResponse));
    }

    /**
     * Update object
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update object", description = "Update object data")
    public ResponseEntity<ObjectResponse> updateObject(
            @PathVariable UUID id,
            @RequestParam UUID tenantId,
            @Valid @RequestBody UpdateObjectRequest request) {
        KernelObject updated = objectService.updateObject(
            tenantId,
            id,
            request.getData(),
            "system" // TODO: Extract from SecurityContext
        );
        
        return ResponseEntity.ok(toResponse(updated));
    }

    /**
     * Delete object (soft delete)
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete object", description = "Soft delete an object")
    public ResponseEntity<Void> deleteObject(
            @PathVariable UUID id,
            @RequestParam UUID tenantId) {
        objectService.deleteObject(
            tenantId,
            id,
            "system" // TODO: Extract from SecurityContext
        );
        
        return ResponseEntity.noContent().build();
    }

    /**
     * Restore deleted object
     */
    @PostMapping("/{id}/restore")
    @Operation(summary = "Restore object", description = "Restore a soft-deleted object")
    public ResponseEntity<ObjectResponse> restoreObject(
            @PathVariable UUID id,
            @RequestParam UUID tenantId) {
        KernelObject restored = objectService.restoreObject(
            tenantId,
            id,
            "system" // TODO: Extract from SecurityContext
        );
        
        return ResponseEntity.ok(toResponse(restored));
    }

    /**
     * Search objects
     */
    @GetMapping("/search")
    @Operation(summary = "Search objects", description = "Search objects by code pattern")
    public ResponseEntity<Page<ObjectResponse>> searchObjects(
            @RequestParam UUID tenantId,
            @RequestParam String query,
            Pageable pageable) {
        Page<KernelObject> results = objectService.searchObjects(tenantId, query, pageable);
        return ResponseEntity.ok(results.map(this::toResponse));
    }

    /**
     * Convert entity to DTO
     */
    private ObjectResponse toResponse(KernelObject object) {
        return ObjectResponse.builder()
            .id(object.getId())
            .tenantId(object.getTenantId())
            .objectTypeCode(object.getObjectTypeCode())
            .objectCode(object.getObjectCode())
            .data(object.getData())
            .status(object.getStatus())
            .version(object.getVersion())
            .isDeleted(object.getIsDeleted())
            .createdAt(object.getCreatedAt())
            .createdBy(object.getCreatedBy())
            .modifiedAt(object.getModifiedAt())
            .modifiedBy(object.getModifiedBy())
            .metadata(object.getMetadata())
            .build();
    }
}
