CREATE TABLE chat_input_summarized
(
    requestId         STRING PRIMARY KEY NOT ENFORCED,
    metadata          ROW(`input` STRING, `userId` STRING, `messageId` STRING, `history` STRING)
) DISTRIBUTED INTO 1 BUCKETS
    WITH
        (
        'changelog.mode' = 'append',
        'kafka.cleanup-policy' = 'compact',
        'value.fields-include' = 'all',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry'
        );
