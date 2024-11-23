package io.confluent.pie.search.models;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer;
import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializerConfig;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

/**
 * Search request deserializer
 */
@Slf4j
public class SearchRequestDeserializer extends KafkaJsonSchemaDeserializer<SearchRequest> {
    public SearchRequestDeserializer(String srUrl, Credentials srCredentials) {
        // Load secret
        Map<String, String> properties = new HashMap<>();
        properties.put(KafkaJsonSchemaDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, srUrl);
        properties.put(KafkaJsonSchemaDeserializerConfig.JSON_VALUE_TYPE, SearchRequest.class.getName());

        if (srCredentials != null) {
            // Support basic auth
            properties.put(KafkaJsonSchemaDeserializerConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "USER_INFO");
            properties.put(KafkaJsonSchemaDeserializerConfig.USER_INFO_CONFIG, srCredentials.username() + ":" + srCredentials.password());
        }

        super.configure(properties, false);

    }

    public SearchRequest deserialize(byte[] data) {
        return super.deserialize(data);
    }
}
