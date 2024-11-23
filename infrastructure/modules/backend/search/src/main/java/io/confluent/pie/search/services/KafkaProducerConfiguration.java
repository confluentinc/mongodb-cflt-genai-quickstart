package io.confluent.pie.search.services;

import io.confluent.pie.search.models.Credentials;
import io.confluent.pie.search.tools.SecretsUtils;
import lombok.Getter;

import java.io.IOException;

/**
 * Configuration for the KafkaProducer
 */
@Getter
public class KafkaProducerConfiguration extends SearchRequestDeserializerConfiguration {

    private final Credentials ccCredentials;
    private final String brokerUrl;

    public KafkaProducerConfiguration() throws IOException {
        // Get the secret value
        final String secretKey = System.getenv("KAFKA_SECRET_KEY");
        brokerUrl = System.getenv("BROKER");
        ccCredentials = SecretsUtils.getCredentials(secretKey);
    }

    public KafkaProducerConfiguration(String srURL, Credentials srCredentials, Credentials ccCredentials, String brokerUrl) {
        super(srURL, srCredentials);

        this.ccCredentials = ccCredentials;
        this.brokerUrl = brokerUrl;
    }
}
