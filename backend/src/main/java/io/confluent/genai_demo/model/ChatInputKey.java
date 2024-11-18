package io.confluent.genai_demo.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Builder;

@Builder
@Schema(value = """
        {
           "properties": {
             "userId": {
               "connect.index": 0,
               "type": "string"
             }
           },
           "required": [
             "userId"
           ],
           "title": "Record",
           "type": "object"
         }
        """, refs = {})
public record ChatInputKey(String userId) {
}
