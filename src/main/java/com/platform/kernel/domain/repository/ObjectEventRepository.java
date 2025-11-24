package com.platform.kernel.domain.repository;

import com.platform.kernel.domain.model.ObjectEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Repository for ObjectEvent entity
 */
@Repository
public interface ObjectEventRepository extends JpaRepository<ObjectEvent, UUID> {

    /**
     * Find all events for an object
     */
    List<ObjectEvent> findByObjectIdOrderByCreatedAtDesc(UUID objectId);

    /**
     * Find events by status
     */
    Page<ObjectEvent> findByStatus(String status, Pageable pageable);

    /**
     * Find events by type
     */
    Page<ObjectEvent> findByEventType(String eventType, Pageable pageable);

    /**
     * Find pending events (to be published)
     */
    List<ObjectEvent> findByStatusAndNextRetryAtLessThanEqualOrderByCreatedAtAsc(
            String status, LocalDateTime now, Pageable pageable);

    /**
     * Find failed events that can be retried
     */
    @Query("SELECT e FROM ObjectEvent e WHERE e.status = 'FAILED' " +
           "AND e.retryCount < e.maxRetries " +
           "AND (e.nextRetryAt IS NULL OR e.nextRetryAt <= :now) " +
           "ORDER BY e.createdAt ASC")
    List<ObjectEvent> findRetriableEvents(@Param("now") LocalDateTime now, Pageable pageable);

    /**
     * Find events in dead letter queue
     */
    List<ObjectEvent> findByStatusOrderByCreatedAtDesc(String status, Pageable pageable);

    /**
     * Count events by status
     */
    long countByStatus(String status);

    /**
     * Find events within date range
     */
    Page<ObjectEvent> findByCreatedAtBetween(
            LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);

    /**
     * Delete old published events (cleanup)
     */
    @Query("DELETE FROM ObjectEvent e WHERE e.status = 'PUBLISHED' " +
           "AND e.publishedAt < :olderThan")
    void deletePublishedEventsOlderThan(@Param("olderThan") LocalDateTime olderThan);
}
