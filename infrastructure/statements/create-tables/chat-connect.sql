CREATE TABLE
    chat_connect (
        `key` STRING PRIMARY KEY NOT ENFORCED,
        `val` STRING
    ) DISTRIBUTED INTO 1 BUCKETS
WITH
    ('key.format' = 'raw', 'value.format' = 'raw');