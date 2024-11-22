CREATE TABLE
    chat_input (
                   sessionId STRING PRIMARY KEY NOT ENFORCED,
                   userId STRING,
                   messageId STRING,
                   input String,
                   createdAt TIMESTAMP_LTZ(3),
                   WATERMARK FOR createdAt AS createdAt
) DISTRIBUTED INTO 1 BUCKETS
    WITH
        (
            'changelog.mode' = 'append',
            'key.format' = 'json-registry',
            'value.format' = 'json-registry',
            'value.fields-include' = 'all'
        );

