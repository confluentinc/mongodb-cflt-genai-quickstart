package org.confluent.pie.search.models;


import org.apache.commons.lang3.tuple.Pair;
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
     * @return SearchResults object
     */
    public static SearchResults from(Pair<SearchRequest, List<Document>> products) {
        return new SearchResults(
                products.getLeft().requestId(),
                products.getRight().toArray(Document[]::new),
                products.getLeft().metadata());
    }

}
