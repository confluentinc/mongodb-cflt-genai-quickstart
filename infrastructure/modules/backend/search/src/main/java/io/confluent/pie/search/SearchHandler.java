package io.confluent.pie.search;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import io.confluent.pie.search.models.LambdaKafkaEvent;
import io.confluent.pie.search.models.SearchRequest;
import io.confluent.pie.search.models.SearchRequestDeserializer;
import io.confluent.pie.search.models.SearchResults;
import io.confluent.pie.search.models.SearchResultsKey;
import io.confluent.pie.search.services.DBService;
import io.confluent.pie.search.services.KafkaProducerSupplier;
import io.confluent.pie.search.services.SearchRequestDeserializerSupplier;
import io.confluent.pie.search.services.impl.MongoServiceSupplier;
import io.confluent.pie.search.tools.Lazy;
import io.confluent.pie.search.tools.Pair;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.function.Supplier;


/**
 * Search handler
 */
@Slf4j
public class SearchHandler implements RequestHandler<LambdaKafkaEvent, Boolean> {

    private final Lazy<Producer<SearchResultsKey, SearchResults>> lazyProducer;
    private final Lazy<SearchRequestDeserializer> searchRequestDeserializer;
    private final Lazy<DBService> dbService;
    private final String searchResultTopicName;

    /**
     * Constructor
     *
     * @throws IOException if an error occurs
     */
    public SearchHandler() throws IOException {
        this(new MongoServiceSupplier(),
                new KafkaProducerSupplier(),
                new SearchRequestDeserializerSupplier(),
                System.getenv("SEARCH_RESULT_TOPIC")
        );
    }

    /**
     * Constructor
     *
     * @param mongoServiceSupplier        supplier for mongo service
     * @param producerSupplier            supplier for producer
     * @param requestDeserializerSupplier supplier for search request deserializer
     * @param searchResultTopicName       search result topic name
     */
    public SearchHandler(Supplier<DBService> mongoServiceSupplier,
                         Supplier<Producer<SearchResultsKey, SearchResults>> producerSupplier,
                         SearchRequestDeserializerSupplier requestDeserializerSupplier,
                         String searchResultTopicName) {
        dbService = new Lazy<>(mongoServiceSupplier);
        lazyProducer = new Lazy<>(producerSupplier);
        searchRequestDeserializer = new Lazy<>(requestDeserializerSupplier);
        this.searchResultTopicName = searchResultTopicName;
    }

    /**
     * Handle search request
     *
     * @param searchRecord search request
     * @param context      lambda context
     * @return true if the request was handled
     */
    @Override
    public Boolean handleRequest(LambdaKafkaEvent searchRecord, Context context) {
        log.info("Received search request: {}", searchRecord.eventSource());

        // Deserialize all the search request
        final List<SearchRequest> searchRequests = getAllSearchRequest(searchRecord);

        searchRequests
                .stream()
                .map(request -> Pair.of(
                        request,
                        dbService.get().find(request)))
                .map(products -> new ProducerRecord<>(
                        searchResultTopicName,
                        new SearchResultsKey(products),
                        new SearchResults(products)))
                .forEach(record -> {
                    // Send the record
                    lazyProducer.get().send(record);
                });

        lazyProducer.get().flush();

        return true;
    }

    /**
     * Get all search request
     *
     * @param event kafka event
     * @return list of search request
     */
    private List<SearchRequest> getAllSearchRequest(LambdaKafkaEvent event) {
        final List<SearchRequest> requests = new ArrayList<>();

        event.records().values().forEach(records -> {
            records.forEach(record -> {
                final byte[] value = Base64.getDecoder().decode(record.value());
                final SearchRequest request = searchRequestDeserializer.get().deserialize(value);

                requests.add(request);
            });
        });

        return requests;
    }
}
