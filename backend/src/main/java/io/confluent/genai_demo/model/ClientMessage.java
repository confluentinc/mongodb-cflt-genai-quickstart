package io.confluent.genai_demo.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ClientMessage(@JsonProperty("id") String messageId, String createdAt, String role, String content,
                            String userId) {
}
