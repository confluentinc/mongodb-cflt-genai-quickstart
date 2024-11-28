CREATE TABLE
    chat_input_embeddings (
        requestId STRING PRIMARY KEY NOT ENFORCED,
        embeddings ARRAY < FLOAT >,
        numberOfCandidate INT,
        `limit` INT,
        minScore DOUBLE,
        metadata ROW (
            `input` STRING,
            `userId` STRING,
            `messageId` STRING,
            `history` STRING
        )
    ) DISTRIBUTED INTO 1 BUCKETS
WITH
    (
        'changelog.mode' = 'append',
        'kafka.cleanup-policy' = 'compact',
        'value.fields-include' = 'all',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry'
    );