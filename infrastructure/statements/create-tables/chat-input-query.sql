CREATE TABLE
    chat_input_query (
        requestId STRING PRIMARY KEY NOT ENFORCED,
        query STRING,
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
        'value.format' = 'json-registry',
        'kafka.consumer.isolation-level' = 'read-uncommitted'
    );