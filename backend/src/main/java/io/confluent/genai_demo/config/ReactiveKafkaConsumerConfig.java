package io.confluent.genai_demo.config;

import io.confluent.genai_demo.model.ChatInput;
import io.confluent.genai_demo.model.ChatInputKey;
import io.confluent.genai_demo.model.ChatOutput;
import io.confluent.genai_demo.model.ChatOutputKey;
import lombok.Getter;
import lombok.experimental.FieldDefaults;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.reactive.ReactiveKafkaConsumerTemplate;
import reactor.kafka.receiver.ReceiverOptions;

import java.util.Collections;
import java.util.Map;

@Configuration
@Getter
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class ReactiveKafkaConsumerConfig {

    String chatOutputTopic = "chat_output";

    @Bean
    public ReceiverOptions<ChatOutputKey, ChatOutput> receiverOptions(KafkaProperties kafkaProperties) {
        Map<String, Object> props = kafkaProperties.buildConsumerProperties(null);
        return ReceiverOptions.<ChatOutputKey, ChatOutput>create(props).subscription(Collections.singletonList(chatOutputTopic));
    }

    @Bean
    public ReactiveKafkaConsumerTemplate<ChatOutputKey, ChatOutput> reactiveKafkaConsumerTemplate(ReceiverOptions<ChatOutputKey, ChatOutput> receiverOptions) {
        return new ReactiveKafkaConsumerTemplate<>(receiverOptions);
    }
}
