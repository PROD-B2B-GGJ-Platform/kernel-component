package com.platform.kernel.domain.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.platform.kernel.domain.model.KernelObject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Optional;
import java.util.UUID;

/**
 * CacheService - L1/L2 caching with Redis
 * 
 * Cache Strategy:
 * - L1: Local in-memory cache (future enhancement)
 * - L2: Redis distributed cache
 * 
 * Cache Keys:
 * - kernel:object:{objectId}
 * - kernel:object:code:{tenantId}:{objectTypeCode}:{objectCode}
 * 
 * TTL: 1 hour (configurable)
 * 
 * @author Platform Team
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class CacheService {

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    private static final String CACHE_PREFIX = "kernel:object:";
    private static final Duration DEFAULT_TTL = Duration.ofHours(1);

    /**
     * Cache object by ID
     */
    public void cacheObject(KernelObject object) {
        try {
            String key = buildKey(object.getId());
            String value = objectMapper.writeValueAsString(object);
            
            redisTemplate.opsForValue().set(key, value, DEFAULT_TTL);
            log.debug("Object cached: key={}", key);

            // Also cache by code for faster lookups
            String codeKey = buildCodeKey(
                object.getTenantId(), 
                object.getObjectTypeCode(), 
                object.getObjectCode()
            );
            redisTemplate.opsForValue().set(codeKey, object.getId().toString(), DEFAULT_TTL);

        } catch (Exception e) {
            log.error("Failed to cache object: {}", e.getMessage(), e);
        }
    }

    /**
     * Get cached object by ID
     */
    public Optional<KernelObject> getCachedObject(UUID objectId) {
        try {
            String key = buildKey(objectId);
            String value = redisTemplate.opsForValue().get(key);

            if (value != null) {
                KernelObject object = objectMapper.readValue(value, KernelObject.class);
                log.debug("Object found in cache: key={}", key);
                return Optional.of(object);
            }

        } catch (Exception e) {
            log.error("Failed to get cached object: {}", e.getMessage(), e);
        }

        return Optional.empty();
    }

    /**
     * Get cached object by code
     */
    public Optional<UUID> getCachedObjectIdByCode(
        UUID tenantId,
        String objectTypeCode,
        String objectCode
    ) {
        try {
            String codeKey = buildCodeKey(tenantId, objectTypeCode, objectCode);
            String objectId = redisTemplate.opsForValue().get(codeKey);

            if (objectId != null) {
                log.debug("Object ID found in cache by code: key={}", codeKey);
                return Optional.of(UUID.fromString(objectId));
            }

        } catch (Exception e) {
            log.error("Failed to get cached object by code: {}", e.getMessage(), e);
        }

        return Optional.empty();
    }

    /**
     * Invalidate object cache
     */
    public void invalidateObject(UUID objectId) {
        try {
            String key = buildKey(objectId);
            redisTemplate.delete(key);
            log.debug("Object cache invalidated: key={}", key);

        } catch (Exception e) {
            log.error("Failed to invalidate object cache: {}", e.getMessage(), e);
        }
    }

    /**
     * Invalidate object cache by code
     */
    public void invalidateObjectByCode(
        UUID tenantId,
        String objectTypeCode,
        String objectCode
    ) {
        try {
            String codeKey = buildCodeKey(tenantId, objectTypeCode, objectCode);
            
            // First get the object ID from code cache
            String objectIdStr = redisTemplate.opsForValue().get(codeKey);
            if (objectIdStr != null) {
                UUID objectId = UUID.fromString(objectIdStr);
                
                // Invalidate both caches
                String objectKey = buildKey(objectId);
                redisTemplate.delete(objectKey);
                redisTemplate.delete(codeKey);
                
                log.debug("Object cache invalidated by code: codeKey={}, objectKey={}", 
                    codeKey, objectKey);
            }

        } catch (Exception e) {
            log.error("Failed to invalidate object cache by code: {}", e.getMessage(), e);
        }
    }

    /**
     * Invalidate all objects of a type (when metadata changes)
     */
    public void invalidateObjectType(String objectTypeCode) {
        try {
            String pattern = CACHE_PREFIX + "*";
            // Note: In production, use a more efficient approach (e.g., cache tags)
            log.warn("invalidateObjectType called - requires optimization for production");
            
            // For now, just log. In production, implement cache tagging.
            log.debug("Object type cache invalidation requested: type={}", objectTypeCode);

        } catch (Exception e) {
            log.error("Failed to invalidate object type cache: {}", e.getMessage(), e);
        }
    }

    /**
     * Build cache key for object ID
     */
    private String buildKey(UUID objectId) {
        return CACHE_PREFIX + objectId.toString();
    }

    /**
     * Build cache key for object code
     */
    private String buildCodeKey(UUID tenantId, String objectTypeCode, String objectCode) {
        return String.format("%scode:%s:%s:%s", 
            CACHE_PREFIX, tenantId, objectTypeCode, objectCode);
    }
}

