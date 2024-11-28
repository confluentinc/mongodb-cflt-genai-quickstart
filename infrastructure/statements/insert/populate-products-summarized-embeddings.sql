insert into
    `products_summarized_with_embeddings`
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
    ref_link,
    embeddings
from
    `products_summarized`,
    LATERAL TABLE (ML_PREDICT ('BedrockTitanEmbed', summary));