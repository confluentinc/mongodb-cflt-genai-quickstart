package io.confluent.pie.search.test;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer;
import io.confluent.pie.search.models.SearchResults;

public class SearchResultsDeserializer extends KafkaJsonSchemaDeserializer<SearchResults> {
}
