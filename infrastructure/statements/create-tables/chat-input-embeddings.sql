CREATE TABLE chat_input_embeddings
(
    userId     STRING PRIMARY KEY NOT ENFORCED,
    sessionId  STRING,
    messageId  STRING,
    input      STRING,
    embeddings ARRAY<FLOAT>,
    createdAt  TIMESTAMP_LTZ(3),
    WATERMARK FOR createdAt AS createdAt
) DISTRIBUTED INTO 1 BUCKETS
    WITH
        (
        'changelog.mode' = 'append',
        'kafka.cleanup-policy' = 'compact',
        'value.fields-include' = 'all',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry'
        );
