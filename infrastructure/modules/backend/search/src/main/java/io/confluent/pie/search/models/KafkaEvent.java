package io.confluent.pie.search.models;

import java.util.List;
import java.util.Map;

/**
 * KafkaEvent
 *
 * @param topic         Name of the topic
 * @param partition     Partition the record is from
 * @param offset        Offset of the record
 * @param timestamp     Timestamp of the record
 * @param timestampType Type of the timestamp
 * @param key           Key of the record
 * @param value         Value of the record
 * @param headers       Headers of the record
 */
public record KafkaEvent(String topic, int partition, long offset, long timestamp, String timestampType, String key,
                         String value, List<Map<String, byte[]>> headers) {
}
