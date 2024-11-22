CREATE
MODEL ProductSummarization
INPUT (text STRING)
OUTPUT (summary STRING)
COMMENT 'Progressively summarize product information into one concise summary'
WITH (
    'task'='text_generation',
    'provider'='bedrock',
    'bedrock.PARAMS.max_tokens' = '20000',
    'bedrock.connection'='bedrock-claude-3-haiku-connection',
    'bedrock.system_prompt'=
'Progressively summarize the lines of product information provided, condensing all fields into one concise summary without losing information.\n            \n            EXAMPLE\n            Product:\n            Product ID: 12345\n            Product Name: Standard Loan\n            Product Description: A standard loan available to all customers. The loan annual rate is determined based on the customer''s creditworthiness.\n            Product Type: Loan\n            Product Currency: USD\n            Product Term Min Length: 1 year\n            Product Term Max Length: 7 years\n            Product Repayment Frequency: Monthly\n            Product Risk Level: Medium\n            Product Status: Active\n            Product Rate Table: | credit score        | rate |\n| ------------------- | ---- |\n| more than 750       | 3.5  |\n| between 500 and 750 | 5.6  |\n| between 350 and 500 | 8.3  |\n| less than 350       | 12   |\n            Product Created Date: 2022-01-01\n            Product Last Updated Date: 2022-01-01\n            \n            Document:\n            Content: The Standard Loan (Product ID: 12345) is a loan product available in USD with a term length ranging from 1 to 7 years. The loan is repayable monthly and carries a medium risk level. The interest rate varies based on the borrower''s credit score: 3.5% for scores over 750, 5.6% for scores between 500 and 750, 8.3% for scores between 350 and 500, and 12% for scores below 350. This product is currently active and was created on January 1, 2022, with the last update on the same date.\n            END OF EXAMPLE'
);