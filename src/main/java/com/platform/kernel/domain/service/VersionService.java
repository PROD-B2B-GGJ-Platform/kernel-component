package com.platform.kernel.domain.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.model.ObjectVersion;
import com.platform.kernel.domain.repository.ObjectVersionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * VersionService - Manages object version history
 * 
 * @author Platform Team
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class VersionService {

    private final ObjectVersionRepository repository;
    private final ObjectMapper objectMapper;

    /**
     * Create version snapshot
     */
    @Transactional
    public ObjectVersion createVersion(
        KernelObject object,
        String changeType,
        String changeDescription,
        JsonNode oldData
    ) {
        log.debug("Creating version for object: id={}, version={}", 
            object.getId(), object.getVersion());

        // Calculate diff if updating
        JsonNode changeDiff = null;
        if ("UPDATE".equals(changeType) && oldData != null) {
            changeDiff = calculateDiff(oldData, object.getData());
        }

        ObjectVersion version = ObjectVersion.builder()
            .objectId(object.getId())
            .tenantId(object.getTenantId())
            .objectTypeCode(object.getObjectTypeCode())
            .versionNumber(object.getVersion())
            .objectCode(object.getObjectCode())
            .objectName(object.getObjectName())
            .data(object.getData())
            .status(object.getStatus())
            .changeType(changeType)
            .changeDescription(changeDescription)
            .changeDiff(changeDiff)
            .metadata(object.getMetadata())
            .build();

        version = repository.save(version);
        log.info("Version created: id={}, object={}, version={}", 
            version.getId(), object.getId(), version.getVersionNumber());

        return version;
    }

    /**
     * Get version history
     */
    @Transactional(readOnly = true)
    public Page<ObjectVersion> getVersionHistory(UUID objectId, Pageable pageable) {
        return repository.findByObjectIdOrderByVersionNumberDesc(objectId, pageable);
    }

    /**
     * Get specific version
     */
    @Transactional(readOnly = true)
    public Optional<ObjectVersion> getVersion(UUID objectId, Integer versionNumber) {
        return repository.findByObjectIdAndVersionNumber(objectId, versionNumber);
    }

    /**
     * Get latest version number
     */
    @Transactional(readOnly = true)
    public Integer getLatestVersionNumber(UUID objectId) {
        return repository.findLatestVersionNumber(objectId).orElse(0);
    }

    /**
     * Count versions
     */
    @Transactional(readOnly = true)
    public Long countVersions(UUID objectId) {
        return repository.countByObjectId(objectId);
    }

    /**
     * Calculate JSON diff between two versions
     * Returns: {"added": {...}, "modified": {...}, "removed": {...}}
     */
    private JsonNode calculateDiff(JsonNode oldData, JsonNode newData) {
        ObjectNode diff = objectMapper.createObjectNode();
        ObjectNode added = objectMapper.createObjectNode();
        ObjectNode modified = objectMapper.createObjectNode();
        ObjectNode removed = objectMapper.createObjectNode();

        // Find added and modified fields
        newData.fields().forEachRemaining(entry -> {
            String key = entry.getKey();
            JsonNode newValue = entry.getValue();

            if (!oldData.has(key)) {
                // Field added
                added.set(key, newValue);
            } else {
                JsonNode oldValue = oldData.get(key);
                if (!oldValue.equals(newValue)) {
                    // Field modified
                    ObjectNode change = objectMapper.createObjectNode();
                    change.set("old", oldValue);
                    change.set("new", newValue);
                    modified.set(key, change);
                }
            }
        });

        // Find removed fields
        oldData.fields().forEachRemaining(entry -> {
            String key = entry.getKey();
            if (!newData.has(key)) {
                removed.set(key, entry.getValue());
            }
        });

        if (added.size() > 0) diff.set("added", added);
        if (modified.size() > 0) diff.set("modified", modified);
        if (removed.size() > 0) diff.set("removed", removed);

        return diff.size() > 0 ? diff : null;
    }
}

