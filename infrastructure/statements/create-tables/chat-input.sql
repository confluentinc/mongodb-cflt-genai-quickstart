CREATE TABLE
    chat_input (
        sessionId STRING PRIMARY KEY NOT ENFORCED,
        userId STRING,
        messageId STRING,
        `input` STRING,
        history STRING,
        createdAt TIMESTAMP_LTZ (3)
    ) DISTRIBUTED INTO 1 BUCKETS
WITH
    (
        'changelog.mode' = 'append',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry',
        'value.fields-include' = 'all',
        'kafka.consumer.isolation-level' = 'read-uncommitted'
    );