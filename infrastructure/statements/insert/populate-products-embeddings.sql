insert into `products_embeddings`
select
    product_id,
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
    summary,
    embeddings
from `products_summarized`,
     LATERAL TABLE(ML_PREDICT('bedrock_titan_embed', summary));
