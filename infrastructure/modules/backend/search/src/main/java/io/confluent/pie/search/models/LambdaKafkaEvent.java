package io.confluent.pie.search.models;

import java.util.List;
import java.util.Map;

/**
 * Kafka event
 *
 * @param eventSource      Event source
 * @param bootstrapServers Kafka bootstrap servers
 * @param records          Records
 */
public record LambdaKafkaEvent(String eventSource, String bootstrapServers, Map<String, List<KafkaEvent>> records) {
}
