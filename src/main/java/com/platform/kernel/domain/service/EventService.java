package com.platform.kernel.domain.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.platform.kernel.domain.model.KernelObject;
import com.platform.kernel.domain.model.ObjectEvent;
import com.platform.kernel.domain.repository.ObjectEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.concurrent.CompletableFuture;

/**
 * EventService - Publishes events to Kafka
 * 
 * Event Types:
 * - object.created
 * - object.updated
 * - object.deleted
 * - object.versioned
 * 
 * @author Platform Team
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class EventService {

    private final ObjectEventRepository repository;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    private static final String TOPIC_PREFIX = "platform.kernel.";

    /**
     * Publish object created event
     */
    @Async
    @Transactional
    public void publishObjectCreatedEvent(KernelObject object) {
        publishEvent(object, "object.created");
    }

    /**
     * Publish object updated event
     */
    @Async
    @Transactional
    public void publishObjectUpdatedEvent(KernelObject object) {
        publishEvent(object, "object.updated");
    }

    /**
     * Publish object deleted event
     */
    @Async
    @Transactional
    public void publishObjectDeletedEvent(KernelObject object) {
        publishEvent(object, "object.deleted");
    }

    /**
     * Core event publishing logic
     */
    private void publishEvent(KernelObject object, String eventType) {
        try {
            // Build event payload
            ObjectNode payload = objectMapper.createObjectNode();
            payload.put("eventType", eventType);
            payload.put("objectId", object.getId().toString());
            payload.put("tenantId", object.getTenantId().toString());
            payload.put("objectTypeCode", object.getObjectTypeCode());
            payload.put("objectCode", object.getObjectCode());
            payload.put("objectName", object.getObjectName());
            payload.put("version", object.getVersion());
            payload.put("status", object.getStatus());
            payload.set("data", object.getData());
            payload.put("timestamp", LocalDateTime.now().toString());

            String topic = TOPIC_PREFIX + eventType;

            // Save event to database (for tracking and retry)
            ObjectEvent event = ObjectEvent.builder()
                .tenantId(object.getTenantId())
                .objectId(object.getId())
                .objectTypeCode(object.getObjectTypeCode())
                .eventType(eventType)
                .payload(payload)
                .status("PENDING")
                .topic(topic)
                .retryCount(0)
                .maxRetries(3)
                .build();

            event = repository.save(event);
            log.debug("Event saved to database: id={}, type={}", event.getId(), eventType);

            // Publish to Kafka
            String payloadString = objectMapper.writeValueAsString(payload);
            String key = object.getId().toString();

            CompletableFuture<SendResult<String, String>> future = 
                kafkaTemplate.send(topic, key, payloadString);

            // Handle success/failure
            final ObjectEvent savedEvent = event;
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    // Success
                    int partition = result.getRecordMetadata().partition();
                    long offset = result.getRecordMetadata().offset();
                    savedEvent.markAsPublished(partition, offset);
                    repository.save(savedEvent);
                    log.info("Event published to Kafka: topic={}, partition={}, offset={}", 
                        topic, partition, offset);
                } else {
                    // Failed
                    log.error("Failed to publish event to Kafka: {}", ex.getMessage(), ex);
                    savedEvent.incrementRetry();
                    if (!savedEvent.canRetry()) {
                        savedEvent.markAsFailed(ex.getMessage());
                    }
                    repository.save(savedEvent);
                }
            });

        } catch (Exception e) {
            log.error("Error publishing event: {}", e.getMessage(), e);
        }
    }

    /**
     * Retry failed events (called by scheduled job)
     */
    @Transactional
    public void retryFailedEvents() {
        // Implementation for scheduled retry job
        log.debug("Retrying failed events...");
        // TODO: Implement retry logic
    }
}

