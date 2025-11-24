-- ========================================================================
-- Migration V3: Create ggj_object_relationships table
-- Purpose: Object graph structure and relationships
-- ========================================================================

CREATE TABLE ggj_object_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_object_id UUID NOT NULL,
    target_object_id UUID NOT NULL,
    relationship_type VARCHAR(100) NOT NULL,
    cardinality VARCHAR(50) NOT NULL DEFAULT 'MANY_TO_MANY',
    is_bidirectional BOOLEAN NOT NULL DEFAULT TRUE,
    inverse_relationship_type VARCHAR(100),
    strength DOUBLE PRECISION,
    display_order INTEGER,
    metadata JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    
    CONSTRAINT uk_rel_source_target_type UNIQUE (source_object_id, target_object_id, relationship_type),
    CONSTRAINT fk_rel_source FOREIGN KEY (source_object_id) 
        REFERENCES ggj_kernel_objects(id) ON DELETE CASCADE,
    CONSTRAINT fk_rel_target FOREIGN KEY (target_object_id) 
        REFERENCES ggj_kernel_objects(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_rel_source ON ggj_object_relationships(source_object_id);
CREATE INDEX idx_rel_target ON ggj_object_relationships(target_object_id);
CREATE INDEX idx_rel_type ON ggj_object_relationships(relationship_type);
CREATE INDEX idx_rel_source_type ON ggj_object_relationships(source_object_id, relationship_type);
CREATE INDEX idx_rel_target_type ON ggj_object_relationships(target_object_id, relationship_type);

-- Comments
COMMENT ON TABLE ggj_object_relationships IS 'Object graph structure for relationships';
COMMENT ON COLUMN ggj_object_relationships.strength IS 'Relationship strength for weighted graphs';
