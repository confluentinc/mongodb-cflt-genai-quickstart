package org.confluent.pie.search.tools;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializerConfig;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.common.serialization.StringSerializer;
import org.confluent.pie.search.models.Credentials;
import org.confluent.pie.search.models.SearchRequest;
import org.confluent.pie.search.models.SearchResultsSerializer;

import java.io.IOException;
import java.util.Properties;

import static org.apache.kafka.clients.CommonClientConfigs.SECURITY_PROTOCOL_CONFIG;
import static org.apache.kafka.clients.producer.ProducerConfig.*;
import static org.apache.kafka.common.config.SaslConfigs.SASL_JAAS_CONFIG;
import static org.apache.kafka.common.config.SaslConfigs.SASL_MECHANISM;

/**
 * Utility class for loading configuration
 */
@Slf4j
public class ConfigUtils {

    /**
     * Load the configuration
     *
     * @param brokerUrl     Kafka broker URL
     * @param credentials   Kafka credentials
     * @param srUrl         Schema Registry URL
     * @param srCredentials Schema Registry credentials
     * @return the configuration
     * @throws IOException if the configuration cannot be loaded
     */
    public static Properties loadConfig(
            String brokerUrl,
            Credentials credentials,
            String srUrl,
            Credentials srCredentials) throws IOException {

        return new Properties() {{
            // User-specific properties that you must set
            put(BOOTSTRAP_SERVERS_CONFIG, brokerUrl);
            put(KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getCanonicalName());
            put(VALUE_SERIALIZER_CLASS_CONFIG, SearchResultsSerializer.class.getCanonicalName());
            put(ACKS_CONFIG, "all");
            if (credentials != null) {
                final String jaas = "org.apache.kafka.common.security.plain.PlainLoginModule required username='" + credentials.username() + "' password='" + credentials.password() + "';";

                put(SASL_JAAS_CONFIG, jaas);
                put(SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
                put(SASL_MECHANISM, "PLAIN");
            }

            // SR
            put(KafkaJsonSchemaDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, srUrl);
            put(KafkaJsonSchemaDeserializerConfig.JSON_VALUE_TYPE, SearchRequest.class.getName());

            if (srCredentials != null) {
                put(KafkaJsonSchemaDeserializerConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "USER_INFO");
                put(KafkaJsonSchemaDeserializerConfig.USER_INFO_CONFIG, srCredentials.username() + ":" + srCredentials.password());
            }
        }};
    }

}
