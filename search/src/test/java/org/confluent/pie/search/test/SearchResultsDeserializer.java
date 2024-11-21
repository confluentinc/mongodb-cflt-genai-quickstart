package org.confluent.pie.search.test;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer;
import org.confluent.pie.search.models.SearchResults;

public class SearchResultsDeserializer extends KafkaJsonSchemaDeserializer<SearchResults> {
}
