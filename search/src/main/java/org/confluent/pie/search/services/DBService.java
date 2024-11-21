package org.confluent.pie.search.services;

import org.bson.Document;
import org.confluent.pie.search.models.SearchRequest;

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
