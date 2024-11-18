package io.confluent.genai_demo.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Builder;

@Builder
@Schema(value = """
        {
          "properties": {
            "sessionId": {
              "connect.index": 0,
              "type": "string"
            }
          },
          "required": [
            "sessionId"
          ],
          "title": "Record",
          "type": "object"
        }
        """, refs = {})
public record ChatOutputKey(String sessionId) {
}
