-- ========================================================================
-- Migration V5: Create ggj_metadata_cache table
-- Purpose: Cache metadata from admin-tool for autonomous operation
-- ========================================================================

CREATE TABLE ggj_metadata_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    object_type_code VARCHAR(100) NOT NULL UNIQUE,
    object_type_name VARCHAR(200) NOT NULL,
    metadata JSONB NOT NULL,
    attribute_definitions JSONB,
    validation_rules JSONB,
    synced_at TIMESTAMP NOT NULL,
    is_stale BOOLEAN NOT NULL DEFAULT FALSE,
    ttl_minutes INTEGER NOT NULL DEFAULT 60,
    usage_count BIGINT NOT NULL DEFAULT 0,
    last_accessed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX idx_meta_object_type ON ggj_metadata_cache(object_type_code);
CREATE INDEX idx_meta_synced ON ggj_metadata_cache(synced_at);
CREATE INDEX idx_meta_stale ON ggj_metadata_cache(is_stale);

-- GIN index for JSONB
CREATE INDEX idx_meta_metadata_gin ON ggj_metadata_cache USING GIN(metadata);
CREATE INDEX idx_meta_attr_def_gin ON ggj_metadata_cache USING GIN(attribute_definitions);

-- Comments
COMMENT ON TABLE ggj_metadata_cache IS 'Cached metadata from admin-tool for autonomous operation';
COMMENT ON COLUMN ggj_metadata_cache.is_stale IS 'Indicates if cache needs refresh';

