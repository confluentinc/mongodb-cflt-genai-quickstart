package org.confluent.pie.search.models;

/**
 * Search request object
 *
 * @param requestId         unique identifier for the request
 * @param embeddings        embeddings to search for in the index
 * @param numberOfCandidate number of candidate to retrieve from the index
 * @param limit             maximum number of results to return
 * @param minScore          minimum score to consider a result
 */
public record SearchRequest(String requestId, double[] embeddings, int numberOfCandidate, int limit, double minScore) {
}