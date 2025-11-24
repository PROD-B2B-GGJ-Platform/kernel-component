-- ========================================================================
-- Migration V6: Create ggj_outbox_events table
-- Purpose: Transactional outbox pattern for reliable event publishing
-- ========================================================================

CREATE TABLE ggj_outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 5,
    error_message VARCHAR(2000),
    published_at TIMESTAMP,
    kafka_topic VARCHAR(200),
    kafka_partition INTEGER,
    kafka_offset BIGINT,
    next_retry_at TIMESTAMP,
    idempotency_key VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_outbox_status ON ggj_outbox_events(status);
CREATE INDEX idx_outbox_created ON ggj_outbox_events(created_at);
CREATE INDEX idx_outbox_status_created ON ggj_outbox_events(status, created_at);
CREATE INDEX idx_outbox_aggregate ON ggj_outbox_events(aggregate_id);
CREATE INDEX idx_outbox_next_retry ON ggj_outbox_events(next_retry_at) WHERE status = 'FAILED';
CREATE INDEX idx_outbox_idempotency ON ggj_outbox_events(idempotency_key);

-- Comments
COMMENT ON TABLE ggj_outbox_events IS 'Transactional outbox for reliable event publishing';
COMMENT ON COLUMN ggj_outbox_events.idempotency_key IS 'Ensures at-most-once processing';

