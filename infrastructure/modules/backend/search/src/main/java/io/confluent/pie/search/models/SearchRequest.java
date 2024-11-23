package io.confluent.pie.search.models;

import java.util.Map;

/**
 * Search request object
 *
 * @param requestId         unique identifier for the request
 * @param embeddings        embeddings to search for in the index
 * @param numberOfCandidate number of candidate to retrieve from the index
 * @param limit             maximum number of results to return
 * @param minScore          minimum score to consider a result
 * @param metadata          additional metadata to pass to the search
 */
public record SearchRequest(String requestId, double[] embeddings, int numberOfCandidate, int limit, double minScore,
                            Map<String, Object> metadata) {

    public SearchRequest(String requestId, double[] embeddings, int numberOfCandidate, int limit, double minScore, Map<String, Object> metadata) {
        this.requestId = requestId;
        this.embeddings = embeddings;
        this.numberOfCandidate = numberOfCandidate;
        this.limit = limit;
        this.minScore = minScore;
        this.metadata = metadata;
    }

    public SearchRequest(String requestId, double[] embeddings, int numberOfCandidate, int limit, double minScore) {
        this(requestId, embeddings, numberOfCandidate, limit, minScore, null);
    }

    public SearchRequest(String requestId, double[] embeddings, int numberOfCandidate, int limit) {
        this(requestId, embeddings, numberOfCandidate, limit, 0.0, null);
    }

    public SearchRequest(String requestId, double[] embeddings) {
        this(requestId, embeddings, 100, 10, 0.0, null);
    }
}