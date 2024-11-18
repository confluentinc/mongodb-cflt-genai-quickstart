insert into `all_insurance_products_summarized`
select product_id, summary, createdAt
from `all_insurance_products`,
     LATERAL TABLE(ML_PREDICT('ProductSummarization', (
'Product Id: ' || `product_id` || '\nProduct Name: ' || `product_name` || '\nProduct Type: ' || `product_type` || '\nRepayment Frequency: ' || `repayment_frequency` || '\nRate Table: ' || `rate_table` || '\nCoverage Type: ' || `coverage_type` || '\nMin Price: ' || CAST(`min_price` AS STRING) || '\nMax Price: ' || CAST(`max_price` AS STRING) || '\nCurrency: ' || `currency` || '\nReference Link: ' || `refLink`)));