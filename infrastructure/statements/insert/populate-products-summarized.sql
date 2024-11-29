insert into
    `products_summarized`
select
    product_id,
    summary,
    description,
    type,
    name,
    currency,
    term_min_length,
    term_max_length,
    repayment_frequency,
    risk_level,
    status,
    rate_table,
    createdAt,
    updatedAt,
    ref_link
from
    `products`,
    LATERAL TABLE (
        ML_PREDICT (
            'ProductSummarization',
            (
                'Product :\nProduct ID:' || `product_id` || '\nProduct Name: ' || `name` || '\nProduct Type: ' || `type` || '\nProduct Term Min Length: ' || `term_min_length` || '\nProduct Term Max Length: ' || `term_max_length` || '\nRepayment Frequency: ' || `repayment_frequency` || '\nProduct Risk Level: ' || `risk_level` || '\nProduct Status: ' || `status` || '\nRate Table: ' || `rate_table` || '\nProduct Created Date: ' || `createdAt` || '\nProduct Last Updated Date: ' || `updatedAt` || '\nReference Link: ' || `ref_link`
            )
        )
    );