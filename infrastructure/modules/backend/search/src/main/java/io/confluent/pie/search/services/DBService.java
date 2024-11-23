package io.confluent.pie.search.services;

import io.confluent.pie.search.models.SearchRequest;
import org.bson.Document;

import java.util.List;

/**
 * Service to interact with the database
 */
public interface DBService {
    /**
     * Find documents in the database
     *
     * @param request the search request
     * @return the list of documents
     */
    List<Document> find(SearchRequest request);
}
