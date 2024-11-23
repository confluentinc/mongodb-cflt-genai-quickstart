package io.confluent.pie.search.models;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaSerializer;

/**
 * Kafka serializer for SearchResults
 */
public class SearchResultsSerializer extends KafkaJsonSchemaSerializer<SearchResults> {
}
