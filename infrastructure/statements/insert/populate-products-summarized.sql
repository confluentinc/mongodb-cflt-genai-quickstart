insert into
    `products_summarized`
select
    product_id,
    response,
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
            'BedrockGeneralModel',
            (
'
<instructions>
You are a summarization assistant tasked with generating concise, accurate summaries of loan data for indexing in a vector database. Your summary must include all key information such as the required credit score, term of the loan, name of the loan, interest rate, and any other significant details provided in the input. The output should be a single-paragraph summary suitable for indexing purposes. **Do not include any tags (e.g., XML or JSON) in the response. Only provide plain text.**
</instructions>

<context>
This task involves summarizing structured loan objects into natural language. Make sure all important fields are represented accurately, with special attention to differentiating between the loan''s requirements (e.g., required credit score) and other details. The goal is to capture the essence of the loan data so it can be easily retrieved based on similarity.
</context>

<examples>
<example>
<input>
{
  "product_id": "HEQ-12345",
  "description": "A loan product designed for homeowners to access the equity in their property for large expenses.",
  "type": "Home Equity Loan",
  "name": "Home Equity Advantage Loan",
  "currency": "USD",
  "term_min_length": 5,
  "term_max_length": 30,
  "repayment_frequency": "Monthly",
  "risk_level": "Medium",
  "status": "Active",
  "rate_table": "| credit score           \t| rate          \t|\n|------------------------\t|---------------\t|\n| more than 750          \t| 3%            \t|\n| less than equal to 750 \t| not available \t|,
  "createdAt": "2024-11-01T10:00:00Z",
  "updatedAt": "2024-11-15T10:00:00Z",
  "ref_link": "https://www.bankexample.com/products/home-equity-loan"
}
</input>
<output>
The "Home Equity Advantage Loan" is a Home Equity Loan designed for homeowners to access property equity for significant expenses. It is offered in USD, with loan terms ranging from 5 to 30 years and a monthly repayment frequency. This product has a medium risk level and is currently active. The interest rate is 3% for borrowers with a credit score above 750; it is unavailable for those with lower scores.
</output>
</example>
</examples>

<format>
Respond in a concise single-paragraph summary format, including all critical loan details. Avoid introducing extra commentary or unrelated information.
</format>

<persona>
You are a precise and detail-oriented assistant trained to create summaries for structured data. Ensure your tone is professional and factual.
</persona>

<task>
Please process the following loan object and provide a summary:
<loan_object>
{
  "product_id": "' || `product_id` || '",
  "description": "' || `description` || '",
  "type": "' || `type` || '",
  "name": "' || `name` || '",
  "currency": "' || `currency` || '",
  "term_min_length":  ' || `term_min_length` || ',
  "term_max_length": ' || `term_max_length` || ',
  "repayment_frequency": "' || `repayment_frequency` || '",
  "risk_level": "' || `risk_level` || '",
  "status": "' || `status` || '",
  "rate_table": "' || `rate_table` || '"",
  "createdAt": "' || `createdAt` || '",
  "updatedAt": "' || `updatedAt` || '",
  "ref_link": "' || `ref_link` || '"
}
</loan_object>
</task>
'
            )
        )
    );