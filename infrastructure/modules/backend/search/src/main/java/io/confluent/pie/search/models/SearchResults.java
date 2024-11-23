package io.confluent.pie.search.models;

import io.confluent.pie.search.tools.Pair;
import org.bson.Document;

import java.util.List;
import java.util.Map;

/**
 * SearchResults represents the results of a search request
 *
 * @param requestId The request ID
 * @param results   The search results
 * @param metadata  Additional metadata
 */

public record SearchResults(String requestId, Document[] results, Map<String, Object> metadata) {

    /**
     * Create a SearchResults object from a pair of SearchRequest and a list of Products
     *
     * @param products Pair of SearchRequest and List of Products
     */
    public SearchResults(Pair<SearchRequest, List<Document>> products) {
        this(products.getLeft().requestId(),
                products.getRight().toArray(Document[]::new),
                products.getLeft().metadata());
    }

}
