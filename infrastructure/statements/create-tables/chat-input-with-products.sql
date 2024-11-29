CREATE TABLE
    chat_input_with_products (
        requestId STRING PRIMARY KEY NOT ENFORCED,
        results ARRAY < ROW < `product_id` STRING,
        `summary` STRING,
        `description` STRING,
        `type` STRING,
        `name` STRING,
        `currency` STRING,
        `term_min_length` STRING,
        `term_max_length` STRING,
        `repayment_frequency` STRING,
        `risk_level` STRING,
        `status` STRING,
        `rate_table` STRING,
        `createdAt` STRING,
        `updatedAt` STRING,
        `ref_link` STRING > >,
        product_summaries STRING,
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