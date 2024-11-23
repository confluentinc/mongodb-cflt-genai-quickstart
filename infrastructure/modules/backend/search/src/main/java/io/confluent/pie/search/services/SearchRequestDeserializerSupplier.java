package io.confluent.pie.search.services;

import io.confluent.pie.search.models.SearchRequestDeserializer;
import lombok.AllArgsConstructor;

import java.io.IOException;
import java.util.function.Supplier;

/**
 * Supplier for creating a SearchRequestDeserializer.
 */
@AllArgsConstructor
public class SearchRequestDeserializerSupplier implements Supplier<SearchRequestDeserializer> {

    private final SearchRequestDeserializerConfiguration configuration;

    public SearchRequestDeserializerSupplier() throws IOException {
        this(new SearchRequestDeserializerConfiguration());
    }

    @Override
    public SearchRequestDeserializer get() {
        return new SearchRequestDeserializer(configuration.getSrURL(), configuration.getSrCredentials());
    }
}
