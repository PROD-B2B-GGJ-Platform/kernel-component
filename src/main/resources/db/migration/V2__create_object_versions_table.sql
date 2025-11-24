-- ========================================================================
-- Migration V2: Create ggj_object_versions table
-- Purpose: Complete version history and audit trail
-- ========================================================================

CREATE TABLE ggj_object_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    object_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    change_type VARCHAR(50) NOT NULL,
    previous_data JSONB,
    current_data JSONB NOT NULL,
    diff JSONB,
    changed_by VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    change_reason VARCHAR(1000),
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_version_object FOREIGN KEY (object_id) 
        REFERENCES ggj_kernel_objects(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_version_object_id ON ggj_object_versions(object_id);
CREATE INDEX idx_version_object_version ON ggj_object_versions(object_id, version_number);
CREATE INDEX idx_version_created ON ggj_object_versions(created_at);
CREATE INDEX idx_version_type ON ggj_object_versions(change_type);
CREATE INDEX idx_version_user ON ggj_object_versions(changed_by);

-- GIN indexes for JSONB
CREATE INDEX idx_version_previous_gin ON ggj_object_versions USING GIN(previous_data);
CREATE INDEX idx_version_current_gin ON ggj_object_versions USING GIN(current_data);

-- Comments
COMMENT ON TABLE ggj_object_versions IS 'Complete version history for all objects';
COMMENT ON COLUMN ggj_object_versions.diff IS 'JSON diff showing what changed';
