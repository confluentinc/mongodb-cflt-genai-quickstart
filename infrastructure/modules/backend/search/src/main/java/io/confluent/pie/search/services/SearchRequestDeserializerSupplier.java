package io.confluent.pie.search.services;

import io.confluent.pie.search.models.SearchRequestDeserializer;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.util.function.Supplier;

/**
 * Supplier for creating a SearchRequestDeserializer.
 */
@Slf4j
@AllArgsConstructor
public class SearchRequestDeserializerSupplier implements Supplier<SearchRequestDeserializer> {

    private  SearchRequestDeserializerConfiguration configuration;

    public SearchRequestDeserializerSupplier() throws IOException {
    }

    @Override
    public SearchRequestDeserializer get() {
        if (configuration == null) {
            try {
                configuration = new SearchRequestDeserializerConfiguration();
            } catch (IOException e) {
                log.error("Error creating SearchRequestDeserializerConfiguration", e);
                throw new RuntimeException(e);
            }
        }
        return new SearchRequestDeserializer(configuration.getSrURL(), configuration.getSrCredentials());
    }
}
