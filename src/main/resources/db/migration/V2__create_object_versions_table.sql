-- ========================================================================
-- Migration V2: Create ggj_object_versions table
-- Purpose: Complete version history and audit trail
-- ========================================================================

-- Ensure parent table exists first (create if V1 didn't run)
CREATE TABLE IF NOT EXISTS ggj_kernel_objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    object_type_code VARCHAR(100) NOT NULL,
    object_code VARCHAR(200) NOT NULL,
    data JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    modified_at TIMESTAMP,
    modified_by VARCHAR(255),
    metadata JSONB,
    CONSTRAINT uk_kernel_obj_tenant_type_code UNIQUE (tenant_id, object_type_code, object_code)
);

-- Create indexes for parent table if they don't exist
CREATE INDEX IF NOT EXISTS idx_kernel_obj_tenant_type ON ggj_kernel_objects(tenant_id, object_type_code);
CREATE INDEX IF NOT EXISTS idx_kernel_obj_tenant_code ON ggj_kernel_objects(tenant_id, object_code);
CREATE INDEX IF NOT EXISTS idx_kernel_obj_status ON ggj_kernel_objects(status);
CREATE INDEX IF NOT EXISTS idx_kernel_obj_created ON ggj_kernel_objects(created_at);
CREATE INDEX IF NOT EXISTS idx_kernel_obj_deleted ON ggj_kernel_objects(is_deleted);
CREATE INDEX IF NOT EXISTS idx_kernel_obj_data_gin ON ggj_kernel_objects USING GIN(data);

-- Now create the versions table
CREATE TABLE IF NOT EXISTS ggj_object_versions (
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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraint only if it doesn't exist and parent table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ggj_kernel_objects')
       AND NOT EXISTS (
           SELECT 1 FROM information_schema.table_constraints 
           WHERE constraint_name = 'fk_version_object' 
           AND table_name = 'ggj_object_versions'
       ) THEN
        ALTER TABLE ggj_object_versions
        ADD CONSTRAINT fk_version_object FOREIGN KEY (object_id) 
            REFERENCES ggj_kernel_objects(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Indexes (idempotent)
CREATE INDEX IF NOT EXISTS idx_version_object_id ON ggj_object_versions(object_id);
CREATE INDEX IF NOT EXISTS idx_version_object_version ON ggj_object_versions(object_id, version_number);
CREATE INDEX IF NOT EXISTS idx_version_created ON ggj_object_versions(created_at);
CREATE INDEX IF NOT EXISTS idx_version_type ON ggj_object_versions(change_type);
CREATE INDEX IF NOT EXISTS idx_version_user ON ggj_object_versions(changed_by);

-- GIN indexes for JSONB
CREATE INDEX IF NOT EXISTS idx_version_previous_gin ON ggj_object_versions USING GIN(previous_data);
CREATE INDEX IF NOT EXISTS idx_version_current_gin ON ggj_object_versions USING GIN(current_data);

-- Comments
COMMENT ON TABLE ggj_object_versions IS 'Complete version history for all objects';
COMMENT ON COLUMN ggj_object_versions.diff IS 'JSON diff showing what changed';
