package io.confluent.genai_demo.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Builder;
@Schema(value = """
        {
          "properties": {
            "output": {
              "connect.index": 1,
              "oneOf": [
                {
                  "type": "null"
                },
                {
                  "type": "string"
                }
              ]
            },
            "userId": {
              "connect.index": 0,
              "oneOf": [
                {
                  "type": "null"
                },
                {
                  "type": "string"
                }
              ]
            }
          },
          "title": "Record",
          "type": "object"
        }
        """,
        refs = {})
@Builder
public record ChatOutput(String userId, String output) {
}
