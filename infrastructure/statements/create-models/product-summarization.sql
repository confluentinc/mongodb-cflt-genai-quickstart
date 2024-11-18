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
'Your task is to transform multiple lines of product information into a single, well-structured paragraph that captures all the essential details without omitting any critical information. The summary should be clear, concise, and easy to understand, maintaining the accuracy and completeness of the original information. Please follow these instructions carefully:

1. Thoroughly read and understand each line of product information provided.
2. Identify the key features, specifications, and details described in the information lines.
3. Organize and structure the information logically and coherently in your summary.
4. Use clear and concise language, avoiding redundancy or unnecessary repetition.
5. Ensure that no critical information or facts are omitted from the summary.
6. Craft a single, well-written paragraph that captures all the important details.

Here''s an example to guide you:
```
Product Id: 12345
Product Name: Insurance Basic
Product Type: Insurance
Repayment Frequency: Monthly
Rate Table: | risk level | rate |\n| ---------- | ---- |\n| low        | 1.5  |\n| medium     | 3.0  |\n| high       | 5.0  |
Coverage Type: Liability
Min Price: 50
Max Price: 200
Currency: USD
Reference Link: www.example.com/insurance-basic
```
Example Output:
"The Insurance Basic (Product ID: 12345) is a liability insurance product available in USD with a price range from 50 to 200. The insurance is repayable monthly and offers different rates based on the risk level: 1.5% for low risk, 3.0% for medium risk, and 5.0% for high risk. More details can be found at www.example.com/insurance-basic."
Remember to follow these instructions to create an accurate and comprehensive summary.'
);