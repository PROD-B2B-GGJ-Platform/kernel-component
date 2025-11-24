package com.platform.kernel.service;

import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.model.ObjectVersion;
import com.platform.kernel.domain.repository.ObjectVersionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for ObjectVersion operations
 * 
 * Handles version history and audit trail
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ObjectVersionService {

    private final ObjectVersionRepository versionRepository;

    /**
     * Create new version entry
     */
    @Transactional
    public ObjectVersion createVersion(KernelObject object, String changeType,
                                        Map<String, Object> previousData,
                                        Map<String, Object> currentData,
                                        String changedBy,
                                        String ipAddress,
                                        String userAgent) {
        log.debug("Creating version: objectId={}, type={}, version={}", 
            object.getId(), changeType, object.getVersion());
        
        ObjectVersion version = ObjectVersion.builder()
            .objectId(object.getId())
            .versionNumber(object.getVersion())
            .changeType(changeType)
            .previousData(previousData)
            .currentData(currentData)
            .diff(calculateDiff(previousData, currentData))
            .changedBy(changedBy)
            .ipAddress(ipAddress)
            .userAgent(userAgent)
            .build();
        
        return versionRepository.save(version);
    }

    /**
     * Get version history for an object
     */
    public List<ObjectVersion> getVersionHistory(UUID objectId) {
        return versionRepository.findByObjectIdOrderByVersionNumberDesc(objectId);
    }

    /**
     * Get specific version
     */
    public Optional<ObjectVersion> getVersion(UUID objectId, Integer versionNumber) {
        return versionRepository.findByObjectIdAndVersionNumber(objectId, versionNumber);
    }

    /**
     * Get latest version
     */
    public Optional<ObjectVersion> getLatestVersion(UUID objectId) {
        return versionRepository.findLatestVersion(objectId);
    }

    /**
     * Get object state at specific timestamp (time-travel)
     */
    public Optional<ObjectVersion> getVersionAtTime(UUID objectId, LocalDateTime timestamp) {
        return versionRepository.findVersionAtTime(objectId, timestamp);
    }

    /**
     * Calculate diff between two versions
     */
    private Map<String, Object> calculateDiff(Map<String, Object> previous, Map<String, Object> current) {
        // Simple diff calculation
        // In production, use a proper JSON diff library
        return Map.of(
            "hasChanges", previous != null && !previous.equals(current),
            "timestamp", LocalDateTime.now()
        );
    }
}

