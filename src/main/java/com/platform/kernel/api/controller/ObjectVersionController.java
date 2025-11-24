package com.platform.kernel.api.controller;

import com.platform.kernel.domain.model.ObjectVersion;
import com.platform.kernel.service.ObjectVersionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * REST API for ObjectVersion operations
 */
@RestController
@RequestMapping("/api/v1/kernel/versions")
@RequiredArgsConstructor
@Tag(name = "Object Versions", description = "Version history and audit trail API")
public class ObjectVersionController {

    private final ObjectVersionService versionService;

    /**
     * Get version history for an object
     */
    @GetMapping("/object/{objectId}")
    @Operation(summary = "Get version history", description = "Get complete version history for an object")
    public ResponseEntity<List<ObjectVersion>> getVersionHistory(@PathVariable UUID objectId) {
        List<ObjectVersion> history = versionService.getVersionHistory(objectId);
        return ResponseEntity.ok(history);
    }

    /**
     * Get specific version
     */
    @GetMapping("/object/{objectId}/version/{versionNumber}")
    @Operation(summary = "Get version", description = "Get specific version of an object")
    public ResponseEntity<ObjectVersion> getVersion(
            @PathVariable UUID objectId,
            @PathVariable Integer versionNumber) {
        return versionService.getVersion(objectId, versionNumber)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get latest version
     */
    @GetMapping("/object/{objectId}/latest")
    @Operation(summary = "Get latest version", description = "Get latest version of an object")
    public ResponseEntity<ObjectVersion> getLatestVersion(@PathVariable UUID objectId) {
        return versionService.getLatestVersion(objectId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Time-travel query
     */
    @GetMapping("/object/{objectId}/at")
    @Operation(summary = "Time-travel query", description = "Get object state at specific time")
    public ResponseEntity<ObjectVersion> getVersionAtTime(
            @PathVariable UUID objectId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime timestamp) {
        return versionService.getVersionAtTime(objectId, timestamp)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}

