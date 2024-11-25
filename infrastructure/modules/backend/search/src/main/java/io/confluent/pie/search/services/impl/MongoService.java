package io.confluent.pie.search.services.impl;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.search.FieldSearchPath;
import io.confluent.pie.search.models.Credentials;
import io.confluent.pie.search.models.SearchRequest;
import io.confluent.pie.search.services.DBService;
import lombok.extern.slf4j.Slf4j;
import org.bson.Document;
import org.bson.conversions.Bson;

import java.io.Closeable;
import java.util.ArrayList;
import java.util.List;

import static com.google.common.primitives.Doubles.asList;
import static com.mongodb.client.model.Aggregates.project;
import static com.mongodb.client.model.Aggregates.vectorSearch;
import static com.mongodb.client.model.Projections.*;
import static com.mongodb.client.model.search.SearchPath.fieldPath;

/**
 * Service to interact with MongoDB
 */
@Slf4j
public class MongoService implements Closeable, DBService {

    private final String indexName;
    private final FieldSearchPath fieldSearchPath;
    private final String embeddingsFieldName;
    private final MongoClient mongoClient;
    private final MongoCollection<Document> mongoCollection;

    /**
     * Constructor
     *
     * @param credentials         credentials
     * @param host                host
     * @param dbName              database name
     * @param collectionName      collection name
     * @param indexName           index name
     * @param embeddingsFieldName embeddings field name
     */
    public MongoService(Credentials credentials,
                        String host,
                        String dbName,
                        String collectionName,
                        String indexName,
                        String embeddingsFieldName) {
        final String connectionString = String.format("mongodb+srv://%s:%s@%s/?retryWrites=true&w=majority",
                credentials.username(),
                credentials.password(),
                host);

        this.indexName = indexName;
        this.embeddingsFieldName = embeddingsFieldName;
        fieldSearchPath = fieldPath(embeddingsFieldName);

        mongoClient = MongoClients.create(connectionString);
        final MongoDatabase database = mongoClient.getDatabase(dbName);
        mongoCollection = database.getCollection(collectionName, Document.class);
    }

    @Override
    public void close() {
        if (mongoClient != null) {
            mongoClient.close();
        }
    }

    /**
     * Find products based on the search request
     *
     * @param request search request
     * @return list of products
     */
    public List<Document> find(SearchRequest request) {
        final List<Document> products = new ArrayList<>();
        final boolean hasScoreFilter = request.minScore() > 0;

        final List<Bson> pipeline = List.of(vectorSearch(
                        fieldSearchPath,
                        asList(request.embeddings()),
                        indexName,
                        request.numberOfCandidate(),
                        request.limit()),
                project(fields(
                        exclude(embeddingsFieldName),
                        metaVectorSearchScore("score"))));

        mongoCollection.aggregate(pipeline).forEach(document -> {
            if (hasScoreFilter && document.getDouble("score") < request.minScore()) {
                return;
            }

            products.add(document);
        });

        log.info("Found {} products", products.size());

        return products;
    }
}
