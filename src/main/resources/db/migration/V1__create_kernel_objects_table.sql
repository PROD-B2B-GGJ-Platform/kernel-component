-- ========================================================================
-- Migration V1: Create ggj_kernel_objects table
-- Purpose: Universal object storage with dynamic JSONB schema
-- ========================================================================

CREATE TABLE ggj_kernel_objects (
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

-- Indexes for performance
CREATE INDEX idx_kernel_obj_tenant_type ON ggj_kernel_objects(tenant_id, object_type_code);
CREATE INDEX idx_kernel_obj_tenant_code ON ggj_kernel_objects(tenant_id, object_code);
CREATE INDEX idx_kernel_obj_status ON ggj_kernel_objects(status);
CREATE INDEX idx_kernel_obj_created ON ggj_kernel_objects(created_at);
CREATE INDEX idx_kernel_obj_deleted ON ggj_kernel_objects(is_deleted);

-- GIN index for JSONB queries
CREATE INDEX idx_kernel_obj_data_gin ON ggj_kernel_objects USING GIN(data);

-- Comments
COMMENT ON TABLE ggj_kernel_objects IS 'Universal object storage for all business entities';
COMMENT ON COLUMN ggj_kernel_objects.data IS 'Dynamic JSONB data - schema-less storage';
COMMENT ON COLUMN ggj_kernel_objects.tenant_id IS 'Multi-tenant isolation';
COMMENT ON COLUMN ggj_kernel_objects.object_type_code IS 'Links to admin-tool metadata';
