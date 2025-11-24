package com.platform.kernel.service;

import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.model.OutboxEvent;
import com.platform.kernel.domain.repository.OutboxEventRepository;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for publishing events to Kafka
 * 
 * Uses Transactional Outbox Pattern for reliability
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EventPublisherService {

    private final OutboxEventRepository outboxRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${kernel.events.kafka.topics.object-created}")
    private String objectCreatedTopic;

    @Value("${kernel.events.kafka.topics.object-updated}")
    private String objectUpdatedTopic;

    @Value("${kernel.events.kafka.topics.object-deleted}")
    private String objectDeletedTopic;

    @Value("${kernel.events.outbox.batch-size:100}")
    private int batchSize;

    /**
     * Publish object created event (via Outbox)
     */
    @Transactional
    public void publishObjectCreated(KernelObject object) {
        log.debug("Publishing object.created event: id={}", object.getId());
        
        Map<String, Object> payload = buildEventPayload(object, "object.created");
        
        OutboxEvent outboxEvent = OutboxEvent.builder()
            .aggregateId(object.getId())
            .aggregateType("KernelObject")
            .eventType("object.created")
            .payload(payload)
            .status(OutboxEvent.STATUS_PENDING)
            .build();
        
        outboxEvent.generateIdempotencyKey();
        outboxRepository.save(outboxEvent);
    }

    /**
     * Publish object updated event
     */
    @Transactional
    public void publishObjectUpdated(KernelObject object) {
        log.debug("Publishing object.updated event: id={}", object.getId());
        
        Map<String, Object> payload = buildEventPayload(object, "object.updated");
        
        OutboxEvent outboxEvent = OutboxEvent.builder()
            .aggregateId(object.getId())
            .aggregateType("KernelObject")
            .eventType("object.updated")
            .payload(payload)
            .status(OutboxEvent.STATUS_PENDING)
            .build();
        
        outboxEvent.generateIdempotencyKey();
        outboxRepository.save(outboxEvent);
    }

    /**
     * Publish object deleted event
     */
    @Transactional
    public void publishObjectDeleted(KernelObject object) {
        log.debug("Publishing object.deleted event: id={}", object.getId());
        
        Map<String, Object> payload = buildEventPayload(object, "object.deleted");
        
        OutboxEvent outboxEvent = OutboxEvent.builder()
            .aggregateId(object.getId())
            .aggregateType("KernelObject")
            .eventType("object.deleted")
            .payload(payload)
            .status(OutboxEvent.STATUS_PENDING)
            .build();
        
        outboxEvent.generateIdempotencyKey();
        outboxRepository.save(outboxEvent);
    }

    /**
     * Publish object restored event
     */
    @Transactional
    public void publishObjectRestored(KernelObject object) {
        log.debug("Publishing object.restored event: id={}", object.getId());
        
        Map<String, Object> payload = buildEventPayload(object, "object.restored");
        
        OutboxEvent outboxEvent = OutboxEvent.builder()
            .aggregateId(object.getId())
            .aggregateType("KernelObject")
            .eventType("object.restored")
            .payload(payload)
            .status(OutboxEvent.STATUS_PENDING)
            .build();
        
        outboxEvent.generateIdempotencyKey();
        outboxRepository.save(outboxEvent);
    }

    /**
     * Process pending outbox events (scheduled job)
     */
    @Scheduled(fixedDelayString = "${kernel.events.outbox.poll-interval-ms:5000}")
    @Transactional
    public void processOutboxEvents() {
        log.trace("Processing outbox events...");
        
        // Get pending events
        List<OutboxEvent> pendingEvents = outboxRepository.findByStatusOrderByCreatedAtAsc(
            OutboxEvent.STATUS_PENDING, 
            org.springframework.data.domain.Pageable.ofSize(batchSize)
        );
        
        if (pendingEvents.isEmpty()) {
            return;
        }
        
        log.info("Processing {} pending outbox events", pendingEvents.size());
        
        for (OutboxEvent event : pendingEvents) {
            try {
                publishToKafka(event);
            } catch (Exception ex) {
                log.error("Failed to publish event: id={}", event.getId(), ex);
                event.markAsFailed(ex.getMessage());
                outboxRepository.save(event);
            }
        }
    }

    /**
     * Retry failed events (scheduled job)
     */
    @Scheduled(fixedDelayString = "${kernel.events.outbox.poll-interval-ms:5000}")
    @Transactional
    public void retryFailedEvents() {
        List<OutboxEvent> retriableEvents = outboxRepository.findReadyForRetry(
            LocalDateTime.now(),
            org.springframework.data.domain.Pageable.ofSize(batchSize)
        );
        
        if (retriableEvents.isEmpty()) {
            return;
        }
        
        log.info("Retrying {} failed events", retriableEvents.size());
        
        for (OutboxEvent event : retriableEvents) {
            try {
                publishToKafka(event);
            } catch (Exception ex) {
                log.error("Retry failed for event: id={}", event.getId(), ex);
                event.markAsFailed(ex.getMessage());
                outboxRepository.save(event);
            }
        }
    }

    /**
     * Publish event to Kafka
     */
    @CircuitBreaker(name = "kafka", fallbackMethod = "publishToKafkaFallback")
    @Retry(name = "kafka")
    private void publishToKafka(OutboxEvent event) {
        String topic = getTopicForEventType(event.getEventType());
        String key = event.getAggregateId().toString();
        
        var future = kafkaTemplate.send(topic, key, event.getPayload());
        
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                var metadata = result.getRecordMetadata();
                event.markAsPublished(metadata.topic(), metadata.partition(), metadata.offset());
                outboxRepository.save(event);
                log.debug("Event published: id={}, topic={}, partition={}, offset={}", 
                    event.getId(), metadata.topic(), metadata.partition(), metadata.offset());
            } else {
                log.error("Failed to publish event: id={}", event.getId(), ex);
                throw new RuntimeException("Kafka publish failed", ex);
            }
        });
    }

    /**
     * Fallback when Kafka circuit breaker opens
     */
    private void publishToKafkaFallback(OutboxEvent event, Exception ex) {
        log.warn("Kafka circuit breaker open, event will be retried later: id={}", event.getId());
        event.markAsFailed("Circuit breaker open: " + ex.getMessage());
        outboxRepository.save(event);
    }

    /**
     * Get Kafka topic for event type
     */
    private String getTopicForEventType(String eventType) {
        return switch (eventType) {
            case "object.created" -> objectCreatedTopic;
            case "object.updated" -> objectUpdatedTopic;
            case "object.deleted" -> objectDeletedTopic;
            case "object.restored" -> objectCreatedTopic; // reuse created topic
            default -> throw new IllegalArgumentException("Unknown event type: " + eventType);
        };
    }

    /**
     * Build event payload
     */
    private Map<String, Object> buildEventPayload(KernelObject object, String eventType) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("eventId", java.util.UUID.randomUUID().toString());
        payload.put("eventType", eventType);
        payload.put("timestamp", LocalDateTime.now().toString());
        payload.put("source", "kernel-component");
        payload.put("tenantId", object.getTenantId().toString());
        
        Map<String, Object> data = new HashMap<>();
        data.put("objectId", object.getId().toString());
        data.put("objectTypeCode", object.getObjectTypeCode());
        data.put("objectCode", object.getObjectCode());
        data.put("status", object.getStatus());
        data.put("version", object.getVersion());
        data.put("payload", object.getData());
        
        payload.put("data", data);
        
        return payload;
    }
}

