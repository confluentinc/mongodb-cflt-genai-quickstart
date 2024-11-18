# GenAI Chatbot Demos

This demo showcases how to use confluent cloud with flink to build a chatbot powereed by GenAI. Confluent Cloud enables
real-time data freshness and scalability for the chatbot. With Apache Kafka as its foundation, Confluent Cloud
orchestrates the flow of information between various components of the chatbot. Flink processes the data in real-time
and provides the chatbot with the necessary information to respond to user queries.

## 🚀 Project Structure

```text
.
├── backend # Spring Boot Application
│ └── src
│     └── main
│         ├── java
│         │ └── io
│         │     └── confluent
│         │         └── genai_demo
│         │             ├── config
│         │             ├── controller
│         │             ├── model
│         │             └── service
│         └── resources
│             ├── static
│             └── templates
├── frontend # Astro / React Application
│ ├── public
│ └── src
│     ├── components
│     └── pages
└── infrastructure # Terraform 
```

## Requirements

- [ ] [Confluent Cloud API Keys](https://www.confluent.io/blog/confluent-terraform-provider-intro/#api-key)
- [ ] [Terraform](https://github.com/tfutils/tfenv) (1.9.2 or higher)
- [ ] [Node.js](https://github.com/nvm-sh/nvm) (v20.15 or higher)
- [ ] [Java](https://www.jenv.be/) (v17 or higher)

## Run the Demo

### 1. Bring up the infrastructure

```sh
cd infrastructure
terraform init
terraform apply --var-file terraform.tfvars # populate your tfvars file with your Confluent Cloud API keys
# Save the output from resource-ids into a .env file for step 2
terraform output resource-ids
```

### 2. Start the backend

This backend exposes a rest api on http://localhost:8080/sse/events

```shell title=".env
#.env file
# kafka
BOOTSTRAP_SERVERS=
KAFKA_KEY_ID=
KAFKA_KEY_SECRET=
# confluent cloud schema registry
SCHEMA_REGISTRY_URL=
SCHEMA_REGISTRY_KEY_ID=
SCHEMA_REGISTRY_KEY_SECRET=
# aws creds for bedrock models
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

```sh
cd backend
export $(grep -v '^#' .env | xargs) && ./mvnw spring-boot:run
```

### 3. Start the frontend

```sh
cd frontend
npm run dev # Starts local dev server at `localhost:4321`
```

### 4. Interact with the chatbot

Open your browser and navigate to `http://localhost:4321/` to interact with the chatbot.

### 5. Create flink external sql connections

```sql
confluent
environment use env-d1zzw7
```

```shell
# embedding connection
confluent flink connection create bedrock-titan-embed-connection \
--cloud AWS \
--region us-east-1 \
--type bedrock \
--endpoint https://bedrock-runtime.us-east-1.amazonaws.com/model/amazon.titan-embed-text-v2:0/invoke \
--aws-access-key $AWS_ACCESS_KEY_ID \
--aws-secret-key $AWS_SECRET_ACCESS_KEY

# text generation
confluent flink connection create bedrock-claude-3-haiku-connection \
--cloud AWS \
--region us-east-1 \
--type bedrock \
--endpoint https://bedrock-runtime.us-east-1.amazonaws.com/model/anthropic.claude-3-haiku-20240307-v1:0/invoke \
--aws-access-key $AWS_ACCESS_KEY_ID \
--aws-secret-key $AWS_SECRET_ACCESS_KEY         
```

### 6. Connect to the flink sql shell

```shell
# get the flink compute pool id and environment id from the list command
confluent flink compute-pool list --region us-east-2            
  Current |     ID      |             Name              | Environment | Current CFU | Max CFU | Cloud |  Region   |   Status     
----------+-------------+-------------------------------+-------------+-------------+---------+-------+-----------+--------------
  *       | lfcp-7m5yr2 | genai-demo-flink-compute-pool | env-8gq9rr  |           0 |      30 | AWS   | us-east-2 | PROVISIONED  
```

```shell
# connect your shell to the flink sql shell
confluent flink shell --environment env-8gq9rr --compute-pool lfcp-7m5yr2
```

### 7. Product Indexing

#### a. Create AI Models

```sql
USE `genai-demo`;
-- embeddings
CREATE
MODEL bedrock_titan_embed
INPUT (text STRING)
OUTPUT (embeddings ARRAY<FLOAT>)
WITH ( 'bedrock.connection' ='bedrock-titan-embed-connection', 'task'='embedding','provider'='bedrock');
```

```````sql
-- Product Summarization
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
```````

#### b. Create product tables

```sql
CREATE TABLE
    car_insurance_products
(
    product_id          STRING PRIMARY KEY NOT ENFORCED,
    product_name        STRING,
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
        'key.format' = 'json-registry',
        'value.format' = 'json-registry',
        'value.fields-include' = 'all'
        );

CREATE TABLE
    home_insurance_products
(
    product_id          STRING PRIMARY KEY NOT ENFORCED,
    product_name        STRING,
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
        'key.format' = 'json-registry',
        'value.format' = 'json-registry',
        'value.fields-include' = 'all'
        );

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
```

#### c. Populate the product tables

```sql
INSERT INTO `car_insurance_products`
VALUES ('001',
        'Car Insurance Basic',
        'Liability',
        'Bi-Weekly',
        '| risk level | rate |\n| ---------- | ---- |\n| low        | 1.5  |\n| medium     | 3.0  |\n| high       | 5.0  |',
        499.99,
        599.99,
        'https://example.com/car-insurance/basic',
        'CAD',
        CURRENT_TIMESTAMP),
       ('002',
        'Car Insurance Premium',
        'Comprehensive',
        'Monthly',
        '| risk level | rate |\n| ---------- | ---- |\n| low        | 2.5  |\n| medium     | 4.0  |\n| high       | 6.0  |',
        899.00,
        1099.00,
        'https://example.com/car-insurance/premium',
        'CAD',
        CURRENT_TIMESTAMP);

INSERT INTO `home_insurance_products`
VALUES ('001',
        'Home Insurance Basic',
        'Dwelling',
        'Bi-Anually',
        '| risk level | rate |\n| ---------- | ---- |\n| low        | 1.5  |\n| medium     | 3.0  |\n| high       | 5.0  |',
        799.99,
        999.99,
        'https://example.com/home-insurance/basic',
        'USD',
        CURRENT_TIMESTAMP),
       ('002',
        'Home Insurance Premium',
        'Comprehensive',
        'Monthly',
        '| risk level | rate |\n| ---------- | ---- |\n| low        | 2.5  |\n| medium     | 4.0  |\n| high       | 6.0  |',
        1499.00,
        1999.00,
        'https://example.com/home-insurance/premium',
        'USD',
        CURRENT_TIMESTAMP);

-- populate all insurance products
INSERT INTO all_insurance_products
    (SELECT CONCAT('car_', product_id) AS product_id,
            product_name,
            'car'                      AS product_type,
            coverage_type,
            repayment_frequency,
            rate_table,
            min_price,
            max_price,
            refLink,
            currency,
            createdAt
     FROM car_insurance_products)
UNION ALL
(SELECT CONCAT('home_', product_id) AS product_id,
        product_name,
        'home'                      AS product_type,
        coverage_type,
        repayment_frequency,
        rate_table,
        min_price,
        max_price,
        refLink,
        currency,
        createdAt
 FROM home_insurance_products);
```

#### d. Create a summarized insurance product table

```sql
CREATE TABLE all_insurance_products_summarized
(
    product_id STRING PRIMARY KEY NOT ENFORCED,
    summary    STRING,

    product_name        STRING,
    product_type        STRING,
    coverage_type       STRING,
    repayment_frequency STRING,
    rate_table          STRING,
    min_price DOUBLE,
    max_price DOUBLE,
    refLink             STRING,
    currency            STRING,
    
	createdAt  TIMESTAMP_LTZ (3),
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
```
#### e. Populate the summarized insurance product table
```sql
insert into `all_insurance_products_summarized`
select product_id, summary, product_name, product_type, coverage_type, repayment_frequency, rate_table, min_price, max_price, refLink, currency, createdAt
from `all_insurance_products`,
     LATERAL TABLE(ML_PREDICT('ProductSummarization', (
'Product Id: ' || `product_id` || '\nProduct Name: ' || `product_name` || '\nProduct Type: ' || `product_type` || '\nRepayment Frequency: ' || `repayment_frequency` || '\nRate Table: ' || `rate_table` || '\nCoverage Type: ' || `coverage_type` || '\nMin Price: ' || CAST(`min_price` AS STRING) || '\nMax Price: ' || CAST(`max_price` AS STRING) || '\nCurrency: ' || `currency` || '\nReference Link: ' || `refLink`)));
```

#### f. Store aggregated product data
```sql
-- We require a primary key to be used for temporal joins operation on a particular dataset
CREATE TABLE
    `all_insurance_products_summarized_aggregated`
(
    `primary_key` STRING PRIMARY KEY NOT ENFORCED,
    `summarized_products`    STRING,
    `createdAt`   TIMESTAMP_LTZ(3),
    WATERMARK FOR `createdAt` AS `createdAt`
) DISTRIBUTED INTO 1 BUCKETS
WITH
    (
        'kafka.cleanup-policy' = 'compact',
        'value.fields-include' = 'all',
        'key.format' = 'json-registry',
        'value.format' = 'json-registry'
    );

insert into `all_insurance_products_summarized_aggregated`
select 'blah' as primary_key, LISTAGG(`summary`, '\n\n') as summarized_products, now() as `createdAt`
from `all_insurance_products_summarized`;
```

#### g. Embeddings: create table and populate
```sql
CREATE TABLE all_insurance_products_embeddings
(
    product_id STRING PRIMARY KEY NOT ENFORCED,
	embeddings ARRAY<FLOAT>,
    summary        STRING,
    product_name        STRING,
    product_type        STRING,
    coverage_type       STRING,
    repayment_frequency STRING,
    rate_table          STRING,
    min_price DOUBLE,
    max_price DOUBLE,
    refLink             STRING,
    currency            STRING,
createdAt  TIMESTAMP_LTZ (3),
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

insert into `all_insurance_products_embeddings`
select product_id, embeddings, summary, product_name, product_type, coverage_type, repayment_frequency, rate_table, min_price, 
       max_price, refLink, currency, createdAt from `all_insurance_products_summarized`, 
LATERAL TABLE(ML_PREDICT('bedrock_titan_embed', summary));
```

### 8. Chatbot Assistant

#### a. Create Ai Chat Assistant Model

``````sql
CREATE
MODEL AlexAiChatAssistant
INPUT (text STRING)
OUTPUT (response STRING)
COMMENT 'Alex AI Sales Chat Assistant'
WITH (
    'task'='text_generation',
    'provider'='bedrock',
    'bedrock.PARAMS.max_tokens' = '200000',
    'bedrock.connection'='bedrock-claude-3-haiku-connection',
    'bedrock.system_prompt'=
'The AI embodies Alex, an insurance agent at Friendly Neighbourhood Insurance Corp. Dedicated to ethical salesmanship, Alex prioritizes the customer''s need, avoiding overly aggressive sales tactics and unnecessary disclosure of sensitive information.

Guiding Principles for Customer Interaction:
1. Product Discussion: Briefly describe the range of insurance products available, focusing on their relevance to each customer without revealing internal pricing or coverage metrics.
2. Eligibility and Negotiation: In cases of ineligibility for particular policies, Alex explores alternative solutions, always ensuring products match the customer''s needs without compromising coverage quality or cost-effectiveness.
3. Communication Style: Tailor communication based on the customer’s age to maintain a professional yet relatable interaction. Use an engaging approach for younger customers and a more formal tone for those over 30.
4. Effective Customer Engagement: To initiate conversations, Alex uses the prompt: "Hi, I''m Alex from Friendly Neighbourhood Insurance Corp, how can I assist with your insurance needs today?”

Ensure any historical customer interactions or summaries provided are succinct, highlighting essential insights or actions without unnecessary detail.

Here''''s an example to guide you:
```
Products: The Insurance Basic (Product ID: 12345) is a liability insurance product available in USD with a price range from 50 to 200. The insurance is repayable monthly and offers different rates based on the risk level: 1.5% for low risk, 3.0% for medium risk, and 5.0% for high risk. More details can be found at www.example.com/insurance-basic."
Input: "user: hello\nassistant: Hi there! I''m Alex from Friendly Neighbourhood Insurance Corp. It''s great that you''re considering insurance options, and I''m here to assist you in finding the best match for your needs. At Friendly Neighbourhood Insurance Corp, we offer a variety of insurance products tailored to different needs, including auto, home, health, and life insurance. Our goal is to ensure that you receive coverage that not only meets your needs but also aligns with your budget user: i''m looking to purchase insurance"
```

Example Output:
"Without getting too into the specifics, our products come with flexible coverage options designed to provide peace of mind, whether it''s protecting your car, home, health, or providing for your loved ones. Depending on your situation, we have plans that can be customized to your needs, ensuring you''re not paying for unnecessary coverage.

If you could share a bit more about what you''re looking for, I can guide you through our products more precisely. Are you looking to insure something specific, or are you interested in exploring a range of options?"');
``````

#### b. Store chatbot responses

```sql
insert into `chat_output`
select sessionId, userId, response as `output`
from `chat_input` /*+ OPTIONS('scan.startup.mode'='latest-offset') */
         left join `all_insurance_products_summarized_aggregated` for system_time as of chat_input.`createdAt`
                   on chat_input.`userId` = all_insurance_products_summarized_aggregated.`primary_key`,
     LATERAL TABLE(ML_PREDICT('AlexAiChatAssistant',('Products: ' || COALESCE(`summarized_products`, 'default')|| '\n\n' || 'Input: '|| `input`)));
```


```sql
INSERT INTO `home_insurance_products`
VALUES ('003',
        'Home Insurance Custom',
        'Dwelling',
        'Bi-weekly',
        '| risk level | rate |\n| ---------- | ---- |\n| low        | 1.5  |\n| medium     | 3.0  |\n| high       | 5.0  |',
        199.99,
        299.99,
        'https://example.com/home-insurance/custom',
        'USD',
        CURRENT_TIMESTAMP);
```

### 9. Sending Data with Embeddings to MongoDB Atlas

#### a. Atlas Configuration

1. The Atlas cluster must be using the same cloud provider and be in the same region as the CC cluster.
2. Create/open a database and collection on the Atlas cluster, make note of the credentials and cluster address.

#### b. Atlas Sink Connector

1. Create a managed MongoDB Atlas Sink connector (plugin name = `MongoDbAtlasSink`)
2. Enter the connection details and use the default options, but make sure the "Input Kafka record value format" is set to `JSON_SR`. 
3. Go back to Atlas: Network Access (left bar, under the SECURITY category), either add all the CC IP addresses (provided during the configuration of the connector) or if it's a test environment, select 0.0.0.0 to open the access to all external IPs.
4. Save the connector.

#### c Chat input embeddings

```sql
CREATE TABLE chat_input_embeddings 
(  
    userId STRING PRIMARY KEY NOT ENFORCED,  
    sessionId    STRING,                   
    messageId    STRING,                   
    input        STRING,  
    embeddings   ARRAY<FLOAT>,
    createdAt    TIMESTAMP_LTZ(3),  
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

insert into `chat_input_embeddings`
select userId, sessionId, messageId, input, embeddings, createdAt 
from `chat_input`, LATERAL TABLE(ML_PREDICT('bedrock_titan_embed', input));
```

#### d Federated search in MongoDB Atlas 

```sql
set 'sql.secrets.mongokey' = '<password>';    
    
CREATE TABLE mongodb (
    product_id          STRING, 
    summary             STRING,
    product_name        STRING,
    product_type        STRING,
    coverage_type       STRING,
    repayment_frequency STRING,
    rate_table          STRING,
    min_price           DOUBLE,
    max_price           DOUBLE,
    refLink             STRING,
    currency            STRING,
) WITH (
    'connector' = 'mongodb',
    'mongodb.password' = '{{sessionconfig/sql.secrets.mongokey}}',
    'mongodb.endpoint' = '<atlas endpoint like mongodb+srv://cluster0.iwuir3o.mongodb.net>',
    'mongodb.username' = '<username>',
    'mongodb.database' = '<atlas database name>',
    'mongodb.collection' = '<collection name>',
    'mongodb.index' = '<index name>',
    'mongodb.path' = 'embeddings', 
    'mongodb.numCandidates' = '<number of candidates>'
)

# with those values, the search would be:

SELECT sessionId, messageId, input, search_results 
FROM chat_input_embeddings, LATERAL TABLE(FEDERATED_SEARCH('mongodb', 3, embeddings));
```

The above search returns:
```
[sessionId: STRING, messageId: STRING, input: STRING, 
search_results: ARRAY<
    ROW<`product_id` STRING, `summary` STRING, `product_name` STRING, 
        `product_type` STRING, `coverage_type` STRING, `repayment_frequency` STRING, `rate_table` STRING, 
        `min_price` DOUBLE, `max_price` DOUBLE, `refLink` STRING, `currency` STRING>
    >] 

```