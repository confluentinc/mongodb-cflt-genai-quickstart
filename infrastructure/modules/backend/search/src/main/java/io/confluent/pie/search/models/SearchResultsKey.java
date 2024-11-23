package io.confluent.pie.search.models;

import io.confluent.pie.search.tools.Pair;
import org.bson.Document;

import java.util.List;

/**
 * SearchResultsKey is a key for the search results.
 *
 * @param requestId the request id
 */
public record SearchResultsKey(String requestId) {

    public SearchResultsKey(Pair<SearchRequest, List<Document>> products) {
        this(products.getLeft().requestId());
    }

}
