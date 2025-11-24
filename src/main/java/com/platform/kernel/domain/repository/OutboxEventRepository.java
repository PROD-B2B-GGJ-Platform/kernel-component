package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.OutboxEvent;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository for OutboxEvent entity
 */
@Repository
public interface OutboxEventRepository extends JpaRepository<OutboxEvent, UUID> {

    /**
     * Find all pending events to be published
     */
    List<OutboxEvent> findByStatusOrderByCreatedAtAsc(String status, Pageable pageable);

    /**
     * Find events ready for retry
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = 'FAILED' " +
           "AND e.retryCount < e.maxRetries " +
           "AND (e.nextRetryAt IS NULL OR e.nextRetryAt <= :now) " +
           "ORDER BY e.createdAt ASC")
    List<OutboxEvent> findReadyForRetry(@Param("now") LocalDateTime now, Pageable pageable);

    /**
     * Find events by aggregate ID
     */
    List<OutboxEvent> findByAggregateIdOrderByCreatedAtDesc(UUID aggregateId);

    /**
     * Find events by idempotency key
     */
    List<OutboxEvent> findByIdempotencyKey(String idempotencyKey);

    /**
     * Count events by status
     */
    long countByStatus(String status);

    /**
     * Delete old published events (cleanup)
     */
    @Query("DELETE FROM OutboxEvent e WHERE e.status = 'PUBLISHED' " +
           "AND e.publishedAt < :olderThan")
    void deletePublishedEventsOlderThan(@Param("olderThan") LocalDateTime olderThan);

    /**
     * Find events that exceeded max retries
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = 'FAILED' " +
           "AND e.retryCount >= e.maxRetries")
    List<OutboxEvent> findExceededMaxRetries();
}

