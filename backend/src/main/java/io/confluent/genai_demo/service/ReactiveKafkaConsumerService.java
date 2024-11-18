package io.confluent.genai_demo.service;

import io.confluent.genai_demo.common.Pair;
import io.confluent.genai_demo.model.ChatInput;
import io.confluent.genai_demo.model.ChatInputKey;
import io.confluent.genai_demo.model.ChatOutput;
import io.confluent.genai_demo.model.ChatOutputKey;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.boot.context.event.ApplicationStartedEvent;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.kafka.core.reactive.ReactiveKafkaConsumerTemplate;
import org.springframework.stereotype.Service;
import reactor.core.publisher.ConnectableFlux;

@Slf4j
@Service
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = lombok.AccessLevel.PRIVATE)
public class ReactiveKafkaConsumerService {
    ReactiveKafkaConsumerTemplate<ChatOutputKey, ChatOutput> reactiveKafkaConsumerTemplate;
    @NonFinal
    @Getter
    ConnectableFlux<Pair<ChatOutputKey, ChatOutput>> kafkaMessageStream;

    @EventListener(ApplicationStartedEvent.class)
    public void onApplicationStarted() {
        kafkaMessageStream = reactiveKafkaConsumerTemplate
                .receiveAutoAck()
                .doOnNext(consumerRecord -> log.info("received key={}, value={} from topic={}, offset={}",
                        consumerRecord.key(),
                        consumerRecord.value(),
                        consumerRecord.topic(),
                        consumerRecord.offset())
                )
                .map(consumerRecord -> Pair.of(consumerRecord.key(), consumerRecord.value()))
                .doOnNext(message -> log.info("successfully consumed {}", message))
                .doOnError(throwable -> log.error("something bad happened while consuming : {}", throwable.getMessage()))
                .doOnTerminate(() -> log.info("terminating consumer"))
                .publish();
    }

    @EventListener(ContextClosedEvent.class)
    public void onApplicationClosed() {
        // figure out how to close the consumer gracefully so we don't have to wait for the timeout
    }

}
