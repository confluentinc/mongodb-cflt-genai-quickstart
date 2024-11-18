package io.confluent.genai_demo.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Builder;

@Schema(value = """
        {
          "properties": {
            "createdAt": {
              "connect.index": 3,
              "oneOf": [
                {
                  "type": "null"
                },
                {
                  "connect.type": "int64",
                  "title": "org.apache.kafka.connect.data.Timestamp",
                  "type": "number"
                }
              ]
            },
            "input": {
              "connect.index": 2,
              "oneOf": [
                {
                  "type": "null"
                },
                {
                  "type": "string"
                }
              ]
            },
            "messageId": {
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
            "sessionId": {
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
public record ChatInput(String sessionId, String messageId, String input, long createdAt) {
}
