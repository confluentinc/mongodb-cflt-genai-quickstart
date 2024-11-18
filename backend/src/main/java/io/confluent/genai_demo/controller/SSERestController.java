package io.confluent.genai_demo.controller;

import io.confluent.genai_demo.common.Pair;
import io.confluent.genai_demo.config.ReactiveKafkaProducerConfig;
import io.confluent.genai_demo.model.ChatInput;
import io.confluent.genai_demo.model.ChatInputKey;
import io.confluent.genai_demo.model.ChatOutput;
import io.confluent.genai_demo.model.ChatOutputKey;
import io.confluent.genai_demo.model.ClientMessage;
import io.confluent.genai_demo.model.ClientMessages;
import io.confluent.genai_demo.service.ReactiveKafkaConsumerService;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.codec.ServerSentEvent;
import org.springframework.kafka.core.reactive.ReactiveKafkaProducerTemplate;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.WebSession;
import reactor.core.publisher.Flux;

import java.time.Instant;
import java.util.Arrays;

@Slf4j
@CrossOrigin
@RestController
@RequestMapping("/sse")
@FieldDefaults(makeFinal = true, level = lombok.AccessLevel.PRIVATE)
@RequiredArgsConstructor
public class SSERestController {

    ReactiveKafkaProducerTemplate<ChatInputKey, ChatInput> reactiveKafkaProducerTemplate;
    ReactiveKafkaConsumerService reactiveKafkaConsumerService;
    ReactiveKafkaProducerConfig reactiveKafkaProducerConfig;

    @PostMapping(value = "/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ServerSentEvent<ChatOutput>> streamEvents(WebSession webSession, @RequestBody ClientMessages clientMessages) {
        log.info("Received request to stream events");
        String sessionId = webSession.getId();
        log.info("Session ID: {}", sessionId);
        log.info("Messages: {}", Arrays.toString(clientMessages.messages()));
        var kafkaMessageToSend = prepareChatInput(clientMessages.messages(), sessionId);
        reactiveKafkaProducerTemplate.send(reactiveKafkaProducerConfig.getChatInputTopic(), kafkaMessageToSend.getLeft(), kafkaMessageToSend.getRight()).subscribe();
        return reactiveKafkaConsumerService.getKafkaMessageStream().autoConnect()
                .filter(chatOutputPair -> chatOutputPair.getLeft().sessionId().equals(sessionId))
                .map(chatOutputPair -> ServerSentEvent.<ChatOutput>builder()
                        .data(chatOutputPair.getRight())
                        .event("chat")
                        .id(chatOutputPair.getLeft().sessionId())
                        .build()).take(1);
    }

    private Pair<ChatInputKey, ChatInput> prepareChatInput(ClientMessage[] messages, String sessionId) {
        // get the last message from the client
        ClientMessage clientMessage = messages[messages.length - 1];
        // Concatenate the messages to form the input. Separate the messages with a <role>: prefix
        var input = Arrays.stream(messages).map(message -> message.role() + ": " + message.content()).reduce((a, b) -> a + "\n" + b).orElse("");
        ChatInput chatInput = ChatInput.builder()
                .sessionId(sessionId)
                .messageId(clientMessage.messageId())
                .input(input)
                .createdAt(Instant.parse(clientMessage.createdAt()).toEpochMilli())
                .build();
        ChatInputKey chatInputKey = ChatInputKey.builder()
                .userId("blah")
                .build();
        return Pair.of(chatInputKey, chatInput);
    }
}