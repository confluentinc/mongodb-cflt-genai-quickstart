# GenAI Chatbot Demos

This demo showcases how to use confluent cloud with flink to build a chatbot powereed by GenAI. Confluent Cloud enables
real-time data freshness and scalability for the chatbot. With Apache Kafka as its foundation, Confluent Cloud
orchestrates the flow of information between various components of the chatbot. Flink processes the data in real-time
and provides the chatbot with the necessary information to respond to user queries.

## 🚀 Project Structure

```text
. # root of the project
├── frontend # Frontend project for the chatbot. This is what will be deployed to s3 and exposed via cloudfront
└── infrastructure # terraform to deploy the infrastructure
    ├── modules
    │     ├── backend # websocket backend & lambdas for the chatbot
    │     │     └── functions # lambda functions
    │     ├── confluent-cloud-cluster # confluent cloud infra. i.e. kafka, flink, schema registry, etc.
    │     └── frontend # s3 bucket and cloudfront distribution
    │         └── scripts # scripts to assist with building and deploying the frontend
    ├── scripts # scripts to assist with deploying the infrastructure
    └── statements # sql statements to register against a flink cluster
        ├── create-models
        ├── create-tables
        └── insert
```

## Requirements

- [ ] [Confluent Cloud API Keys](https://www.confluent.io/blog/confluent-terraform-provider-intro/#api-key)
- [ ] [MongoDB Atlas API Keys](https://www.mongodb.com/developer/products/atlas/mongodb-atlas-with-terraform/)
- [ ] [AWS API Keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)
- [ ] [Docker](https://docs.docker.com/get-docker/)

## Run the Demo

### 1. Bring up the infrastructure

```sh
# Follow the prompts to enter your API keys
./deploy.sh
```

### 2. Bring down the infrastructure

```sh
./destroy.sh
```

### 3. Product Indexing

#### a. Embeddings: create table and populate

```sql
CREATE TABLE all_insurance_products_embeddings
(
    product_id          STRING PRIMARY KEY NOT ENFORCED,
    embeddings          ARRAY<FLOAT>,
    summary             STRING,
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

insert into `all_insurance_products_embeddings`
select product_id,
       embeddings,
       summary,
       product_name,
       product_type,
       coverage_type,
       repayment_frequency,
       rate_table,
       min_price,
       max_price,
       refLink,
       currency,
       createdAt
from `all_insurance_products_summarized`,
     LATERAL TABLE(ML_PREDICT('bedrock_titan_embed', summary));
```

### 4. Chatbot Assistant

#### a. Store chatbot responses

```sql
insert into `chat_output`
select sessionId, userId, response as `output`
from `chat_input` /*+ OPTIONS('scan.startup.mode'='latest-offset') */
         left join `all_insurance_products_summarized_aggregated` for system_time as of chat_input.`createdAt`
                   on chat_input.`userId` = all_insurance_products_summarized_aggregated.`primary_key`,
     LATERAL TABLE(ML_PREDICT('AlexAiChatAssistant',('Products: ' || COALESCE(`summarized_products`, 'default')|| '\n\n' || 'Input: '|| `input`)));
```

### 5. Sending Data with Embeddings to MongoDB Atlas

#### a. Atlas Configuration

1. The Atlas cluster must be using the same cloud provider and be in the same region as the CC cluster.
2. Create/open a database and collection on the Atlas cluster, make note of the credentials and cluster address.

#### b. Atlas Sink Connector

1. Create a managed MongoDB Atlas Sink connector (plugin name = `MongoDbAtlasSink`)
2. Enter the connection details and use the default options, but make sure the "Input Kafka record value format" is set
   to `JSON_SR`.
3. Go back to Atlas: Network Access (left bar, under the SECURITY category), either add all the CC IP addresses (
   provided during the configuration of the connector) or if it's a test environment, select 0.0.0.0 to open the access
   to all external IPs.
4. Save the connector.

#### c Chat input embeddings

```sql
CREATE TABLE chat_input_embeddings
(
    userId     STRING PRIMARY KEY NOT ENFORCED,
    sessionId  STRING,
    messageId  STRING,
    input      STRING,
    embeddings ARRAY<FLOAT>,
    createdAt  TIMESTAMP_LTZ(3),
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
from `chat_input`, LATERAL TABLE (ML_PREDICT('bedrock_titan_embed', input));
```

#### d Federated search in MongoDB Atlas and results into a topic

```sql
set
'sql.secrets.mongokey' = '<password>';

CREATE TABLE mongodb
(
    product_id          STRING,
    summary             STRING,
    product_name        STRING,
    product_type        STRING,
    coverage_type       STRING,
    repayment_frequency STRING,
    rate_table          STRING,
    min_price DOUBLE,
    max_price DOUBLE,
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

CREATE TABLE search_result_table ( 
	`sessionId` STRING, 
	`messageId` STRING, 
	`input` STRING, 
	`search_results` 
	ARRAY<ROW<
		`product_id` STRING, 
		`summary` STRING, 
		`product_name` STRING, 
		`product_type` STRING, 
		`coverage_type` STRING, 
		`repayment_frequency` STRING, 
		rate_table` STRING, 
		`min_price` DOUBLE, 
		`max_price` DOUBLE, 
		`refLink` STRING, 
		`currency` STRING>> 
); 


INSERT INTO search_result_table ( 
	SELECT sessionId,messageId,input,search_results FROM `chat_input_embeddings`, 
		LATERAL TABLE(FEDERATED_SEARCH('mongodb', 3, embedding)) );
```