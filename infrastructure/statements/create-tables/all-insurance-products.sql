CREATE TABLE all_insurance_products
(
    product_id          STRING PRIMARY KEY NOT ENFORCED,
    product_name        STRING,
    product_type        STRING,
    coverage_type       STRING,
    repayment_frequency STRING,
    rate_table          STRING,
    min_price DOUBLE,
    max_price DOUBLE,
    refLink             STRING,
    currency            STRING,
    createdAt           TIMESTAMP_LTZ (3),
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