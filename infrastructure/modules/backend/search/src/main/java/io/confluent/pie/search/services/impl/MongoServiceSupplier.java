package io.confluent.pie.search.services.impl;

import io.confluent.pie.search.services.DBService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.util.function.Supplier;

/**
 * Supplier for creating a MongoService.
 */
@Slf4j
@AllArgsConstructor
public class MongoServiceSupplier implements Supplier<DBService> {

    private MongoServiceConfiguration configuration;

    public MongoServiceSupplier() throws IOException {
    }
    
    /**
     * Create a MongoService.
     *
     * @return the MongoService
     */
    @Override
    public MongoService get() {
        try {
            if (configuration == null) {
                configuration = new MongoServiceConfiguration();
            }

            return new MongoService(
                    configuration.getCredentials(),
                    configuration.getHost(),
                    configuration.getDbName(),
                    configuration.getCollectionName(),
                    configuration.getIndexName(),
                    configuration.getFieldPath());
        } catch (Exception e) {
            log.error("Error creating MongoService.", e);

            throw new RuntimeException(e);
        }
    }
}
