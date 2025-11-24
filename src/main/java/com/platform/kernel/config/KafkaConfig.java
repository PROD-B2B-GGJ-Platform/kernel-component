package com.platform.kernel.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.support.serializer.JsonSerializer;

import java.util.HashMap;
import java.util.Map;

/**
 * Kafka Configuration
 * 
 * Configures:
 * - Kafka topics for events
 * - Producer for publishing events
 * - Idempotent producer for exactly-once semantics
 * 
 * Only enabled when Kafka is available
 */
@Configuration
@org.springframework.boot.autoconfigure.condition.ConditionalOnProperty(
    name = "spring.kafka.enabled",
    havingValue = "true",
    matchIfMissing = false
)
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    @Value("${kernel.events.kafka.topics.object-created}")
    private String objectCreatedTopic;

    @Value("${kernel.events.kafka.topics.object-updated}")
    private String objectUpdatedTopic;

    @Value("${kernel.events.kafka.topics.object-deleted}")
    private String objectDeletedTopic;

    @Value("${kernel.events.kafka.topics.relationship-created}")
    private String relationshipCreatedTopic;

    @Value("${kernel.events.kafka.topics.relationship-deleted}")
    private String relationshipDeletedTopic;

    /**
     * Kafka Producer Factory with idempotence
     */
    @Bean
    public ProducerFactory<String, Object> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        
        // Idempotent producer for exactly-once semantics
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");
        configProps.put(ProducerConfig.RETRIES_CONFIG, 3);
        configProps.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 1);
        
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    /**
     * Kafka Template for publishing events
     */
    @Bean
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    /**
     * Topic: Object Created
     */
    @Bean
    public NewTopic objectCreatedTopic() {
        return TopicBuilder.name(objectCreatedTopic)
            .partitions(10)
            .replicas(3)
            .compact()
            .build();
    }

    /**
     * Topic: Object Updated
     */
    @Bean
    public NewTopic objectUpdatedTopic() {
        return TopicBuilder.name(objectUpdatedTopic)
            .partitions(10)
            .replicas(3)
            .compact()
            .build();
    }

    /**
     * Topic: Object Deleted
     */
    @Bean
    public NewTopic objectDeletedTopic() {
        return TopicBuilder.name(objectDeletedTopic)
            .partitions(10)
            .replicas(3)
            .compact()
            .build();
    }

    /**
     * Topic: Relationship Created
     */
    @Bean
    public NewTopic relationshipCreatedTopic() {
        return TopicBuilder.name(relationshipCreatedTopic)
            .partitions(5)
            .replicas(3)
            .compact()
            .build();
    }

    /**
     * Topic: Relationship Deleted
     */
    @Bean
    public NewTopic relationshipDeletedTopic() {
        return TopicBuilder.name(relationshipDeletedTopic)
            .partitions(5)
            .replicas(3)
            .compact()
            .build();
    }
}

