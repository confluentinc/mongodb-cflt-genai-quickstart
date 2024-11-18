package io.confluent.genai_demo.config;

import io.confluent.genai_demo.model.ChatInput;
import io.confluent.genai_demo.model.ChatInputKey;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.experimental.FieldDefaults;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.reactive.ReactiveKafkaProducerTemplate;
import reactor.kafka.sender.SenderOptions;

import java.util.Map;

@Configuration
@Getter
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReactiveKafkaProducerConfig {

    String chatInputTopic = "chat_input";

    @Bean
    public ReactiveKafkaProducerTemplate<ChatInputKey, ChatInput> reactiveKafkaProducerTemplate(KafkaProperties kafkaProperties) {
        Map<String, Object> props = kafkaProperties.buildProducerProperties(null);
        return new ReactiveKafkaProducerTemplate<>(SenderOptions.create(props));
    }
}
