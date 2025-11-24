-- ========================================================================
-- Migration V4: Create ggj_object_events table
-- Purpose: Event log for Kafka event bus
-- ========================================================================

CREATE TABLE ggj_object_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    object_id UUID NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    kafka_topic VARCHAR(200),
    kafka_partition INTEGER,
    kafka_offset BIGINT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    error_message VARCHAR(2000),
    error_stack_trace TEXT,
    published_at TIMESTAMP,
    last_retry_at TIMESTAMP,
    next_retry_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_event_object FOREIGN KEY (object_id) 
        REFERENCES ggj_kernel_objects(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_event_object_id ON ggj_object_events(object_id);
CREATE INDEX idx_event_status ON ggj_object_events(status);
CREATE INDEX idx_event_type ON ggj_object_events(event_type);
CREATE INDEX idx_event_created ON ggj_object_events(created_at);
CREATE INDEX idx_event_status_created ON ggj_object_events(status, created_at);
CREATE INDEX idx_event_next_retry ON ggj_object_events(next_retry_at) WHERE status = 'FAILED';

-- Comments
COMMENT ON TABLE ggj_object_events IS 'Event log for Kafka event bus with retry mechanism';
COMMENT ON COLUMN ggj_object_events.payload IS 'Complete event payload including object data';
