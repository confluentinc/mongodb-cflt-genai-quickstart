CREATE TABLE products
(
    product_id          STRING PRIMARY KEY NOT ENFORCED,
    description         STRING,
    type                STRING,
    name                STRING,
    currency            STRING,
    term_min_length     STRING,
    term_max_length     STRING,
    repayment_frequency STRING,
    risk_level          STRING,
    status              STRING,
    rate_table          STRING,
    createdAt           TIMESTAMP_LTZ (3),
    updatedAt           TIMESTAMP_LTZ (3),
    ref_link            STRING,
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