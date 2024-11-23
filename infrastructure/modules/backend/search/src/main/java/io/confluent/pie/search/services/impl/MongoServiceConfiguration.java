package io.confluent.pie.search.services.impl;

import io.confluent.pie.search.models.Credentials;
import io.confluent.pie.search.tools.SecretsUtils;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;

/**
 * Configuration for the MongoService
 */
@Slf4j
@Getter
@AllArgsConstructor
public class MongoServiceConfiguration {

    private final Credentials credentials;
    private final String host;
    private final String dbName;
    private final String collectionName;
    private final String indexName;
    private final String fieldPath;

    public MongoServiceConfiguration() throws IOException {
        credentials = SecretsUtils.getCredentials(System.getenv("MONGO_CREDENTIALS"));
        if (credentials == null) {
            log.error("Error creating MongoService: credentials are null.");
            throw new RuntimeException("Error creating MongoService: credentials are null.");
        }

        host = System.getenv("MONGO_HOST");
        dbName = System.getenv("MONGO_DB_NAME");
        collectionName = System.getenv("MONGO_COLLECTION_NAME");
        indexName = System.getenv("MONGO_INDEX_NAME");
        fieldPath = System.getenv("MONGO_FIELD_PATH");
    }
}
