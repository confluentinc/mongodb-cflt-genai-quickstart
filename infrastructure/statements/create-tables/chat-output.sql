CREATE TABLE
    chat_output (
        sessionId STRING PRIMARY KEY NOT ENFORCED,
        userId STRING,
        output STRING
    ) DISTRIBUTED INTO 1 BUCKETS
WITH
    (
        'changelog.mode' = 'append',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry',
        'value.fields-include' = 'all'
    );