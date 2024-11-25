package io.confluent.pie.search.models;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import io.confluent.pie.search.tools.Pair;
import org.bson.Document;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * SearchResults represents the results of a search request
 *
 * @param requestId The request ID
 * @param results   The search results
 * @param metadata  Additional metadata
 */
@Schema(value = """
        {
           "properties":{
              "metadata":{
                 "connect.index":3,
                 "oneOf":[
                    {
                       "type":"null"
                    },
                    {
                       "properties":{
                          "input":{
                             "connect.index":0,
                             "oneOf":[
                                {
                                   "type":"null"
                                },
                                {
                                   "type":"string"
                                }
                             ]
                          },
                          "messageId":{
                             "connect.index":2,
                             "oneOf":[
                                {
                                   "type":"null"
                                },
                                {
                                   "type":"string"
                                }
                             ]
                          },
                          "userId":{
                             "connect.index":1,
                             "oneOf":[
                                {
                                   "type":"null"
                                },
                                {
                                   "type":"string"
                                }
                             ]
                          }
                       },
                       "title":"Record_metadata",
                       "type":"object"
                    }
                 ]
              },
              "product_summaries":{
                 "connect.index":2,
                 "oneOf":[
                    {
                       "type":"null"
                    },
                    {
                       "type":"string"
                    }
                 ]
              },
              "requestId":{
                 "connect.index":0,
                 "type":"string"
              },
              "results":{
                 "connect.index":1,
                 "oneOf":[
                    {
                       "type":"null"
                    },
                    {
                       "items":{
                          "oneOf":[
                             {
                                "type":"null"
                             },
                             {
                                "properties":{
                                   "createdAt":{
                                      "connect.index":12,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "currency":{
                                      "connect.index":5,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "description":{
                                      "connect.index":2,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "name":{
                                      "connect.index":4,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "product_id":{
                                      "connect.index":0,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "rate_table":{
                                      "connect.index":11,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "ref_link":{
                                      "connect.index":14,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "repayment_frequency":{
                                      "connect.index":8,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "risk_level":{
                                      "connect.index":9,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "status":{
                                      "connect.index":10,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "summary":{
                                      "connect.index":1,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "term_max_length":{
                                      "connect.index":7,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "term_min_length":{
                                      "connect.index":6,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "type":{
                                      "connect.index":3,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   },
                                   "updatedAt":{
                                      "connect.index":13,
                                      "oneOf":[
                                         {
                                            "type":"null"
                                         },
                                         {
                                            "type":"string"
                                         }
                                      ]
                                   }
                                },
                                "title":"Record_results",
                                "type":"object"
                             }
                          ]
                       },
                       "type":"array"
                    }
                 ]
              }
           },
           "required":[
              "requestId"
           ],
           "title":"Record",
           "type":"object"
        }
        """, refs = {})
public record SearchResults(String requestId, String product_summaries, Document[] results,
                            Map<String, Object> metadata) {

    /**
     * Create a SearchResults object from a request ID, a list of Products, and metadata
     *
     * @param requestId The request ID
     * @param results   The list of Products
     * @param metadata  Additional metadata
     */
    public SearchResults(String requestId, Document[] results, Map<String, Object> metadata) {
        this(requestId,
                Arrays.stream(results)
                        .map(document -> document.getString("summary"))
                        .collect(Collectors.joining("\n")),
                results,
                metadata);
    }

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
