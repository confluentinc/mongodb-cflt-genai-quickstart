package io.confluent.pie.search.services;

import io.confluent.pie.search.models.SearchResults;
import io.confluent.pie.search.models.SearchResultsKey;
import io.confluent.pie.search.tools.ConfigUtils;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;

import java.io.IOException;
import java.util.Properties;
import java.util.function.Supplier;

import static io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig.AUTO_REGISTER_SCHEMAS;

/**
 * Supplier for creating a KafkaProducer.
 */
@Slf4j
@AllArgsConstructor
public class KafkaProducerSupplier implements Supplier<Producer<SearchResultsKey, SearchResults>> {

    private KafkaProducerConfiguration configuration;

    public KafkaProducerSupplier() throws IOException {
    }

    /**
     * Create a KafkaProducer.
     *
     * @return the KafkaProducer
     */
    @Override
    public Producer<SearchResultsKey, SearchResults> get() {
        try {
            if (configuration == null) {
                configuration = new KafkaProducerConfiguration();
            }

            log.info("Creating Kafka producer");

            // Load the config
            final Properties properties = ConfigUtils.loadConfig(
                    configuration.getBrokerUrl(),
                    configuration.getCcCredentials(),
                    configuration.getSrURL(),
                    configuration.getSrCredentials(),
                    false);

            return new KafkaProducer<>(properties);
        } catch (Throwable e) {
            log.error("Error creating Kafka producer", e);
            throw new RuntimeException(e);
        } finally {
            log.info("Kafka producer created");
        }
    }
}
