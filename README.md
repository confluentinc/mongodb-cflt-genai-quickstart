# GenAI Chatbot Quickstart

This quickstart showcases how to use Confluent Cloud with Flink to build a chatbot powered by GenAI. Confluent Cloud enables
real-time data freshness and scalability for the chatbot.

With Apache Kafka and the [Kora](https://www.confluent.io/kora-cloud-native-apache-kafka-engine/) engine as its foundation, Confluent Cloud
orchestrates the flow of information between various components of the chatbot.

Flink processes the data in real-time, connects with AI models
and provides the chatbot with the necessary information to respond to user queries.

## Table of Contents

- [GenAI Chatbot Quickstart](#genai-chatbot-quickstart)
  - [Table of Contents](#table-of-contents)
  - [Architecture](#architecture)
    - [Document Indexing](#document-indexing)
    - [Chatbot](#chatbot)
    - [Key Concepts](#key-concepts)
  - [Requirements](#requirements)
    - [Docker](#docker)
    - [Access Keys to Cloud Services Providers](#access-keys-to-cloud-services-providers)
      - [Confluent Cloud](#confluent-cloud)
      - [MongoDB Atlas](#mongodb-atlas)
      - [AWS](#aws)
        - [Enable Foundation Model Access](#enable-foundation-model-access)
  - [Run the Quickstart](#run-the-quickstart)
    - [1. Bring up the infrastructure](#1-bring-up-the-infrastructure)
    - [2. Bring down the infrastructure](#2-bring-down-the-infrastructure)

## Architecture

![HLA](./assets/quickstart_architecture.png)

Architecture for handling document indexing and chatbot functionality using a combination of AWS services, Anthropic
Claude, MongoDB Atlas and Confluent Cloud. Below is a breakdown of the architecture and its components:

### Document Indexing

This section focuses on ingesting and processing data for use in downstream applications like search and chatbots.

1. **Data Sources:** Various data sources feed into the system. These could be structured or unstructured data streams.
2. **Summarization:** Anthropic Claude is used to summarize data to extract meaningful information from documents.
3. **Vectorization:** Embeddings are generated for the input data to convert textual information into high-dimensional numerical vectors.
4. **Sink Connector:** Processed data (both summarized content and embeddings) is output via a sink connector to MongoDB Atlas vector database.

### Chatbot

This section demonstrates how the system interacts with user queries in real time.

1. **Frontend:** The frontend handles interactions with users. User inputs are sent to a topic for further processing.
2. **Websocket:** Provides real-time communication between the frontend and backend for immediate responses.
3. **Query Vectorization:** User queries are vectorized using the Embeddings model to transform them into numerical representations. This is done to match queries against stored vectors in the vector search database.
4. **Vector Search:** MongoDB Atlas vector database, retrieves relevant information based on the vectorized query. It searches through embeddings generated during the document indexing phase.
5. **Model Inference:** Anthropic Claude is used for model inference to generate responses.
6. **Output to User:** The system sends the processed results back to the user via the websocket.

### Key Concepts

1. **Embeddings:** These are vector representations of text, allowing the system to handle semantic search.

2. **MongoDB Atlas:** Enables efficient, scalable, and real-time semantic matching of user queries against high-dimensional embeddings to deliver relevant results in the chatbot and document indexing workflows.

3. **Anthropic Claude:** Used for both summarization and generating responses in natural language.

## Requirements

### Docker

The `deploy`script builds everything for you, the only required software is Docker.

Follow the [Get Docker](https://docs.docker.com/get-docker/) instructions to install it on your computer.

### Access Keys to Cloud Services Providers

Once you have `docker` installed, you just need to get keys to authenticate to the various CSPs.

#### Confluent Cloud

![Creating Confluent Cloud Api Keys](./assets/cc-api-keys.mov)

For Confluent Cloud, you need to get a *Cloud resource management* key.

If you don't already have an account, after signing up, click the top right corner menu (AKA the hamburger menu) and select *API keys*.

![cc-api-keys](./assets/cc-api-keys.png)

Click the *+ Add API key* button, select *My Account* and click the *Next* button (bottom right).
If you feel like it, enter a name and description. Click the *Create API Key* (bottom right).

#### MongoDB Atlas

![mongodb-atlas-api-keys](./assets/mongodb-create-api-key.mov)

1. Connect to the Atlas UI. You must have Organization Owner access to Atlas.
2. Select *Organization Access* from the *Access Manager* menu in the navigation bar.
3. Click *Access Manager* in the sidebar. (The Organization Access Manager page displays.)
4. Click *Add new* then *API Key*
5. In the *API Key Information*, enter a description.
6. In the *Organization Permissions* menu, select the *Organization Owner* role. **Important:** Make sure that only the
   *Organization Owner* role is selected, you may have to click the default *Organization Member* to un-select it.
7. Click *Next*, copy the public and private key in a safe place and click *Done*.

Useful links:

- [Grant Programmatic Access to an Organization](https://www.mongodb.com/docs/atlas/configure-api-access/#grant-programmatic-access-to-an-organization)
- [MongoDB Atlas API Keys](https://www.mongodb.com/developer/products/atlas/mongodb-atlas-with-terraform/) (part of a tutorial on Terraform with Atlas)

#### AWS

##### Enable Foundation Model Access

As part of the Quickstart, we use `amazon.titan-embed-text-v2:0` and `anthropic.claude-3-haiku-20240307-v1:0` models. You'll need to navigate through the AWS Console to enable access to these models.

![Enable Foundation Model Access](./assets/aws-enable-foundation-models.mov)

AWS has many security credential types and authentication methods. No matter the one that you wish to use, or that your organization mandates, you'll get a key and secret that will have IAM rights (or policies) attached to it.

The AWS credentials that we need in this step are going to be used by Flink AI to connect to Bedrock.

You can attach on of these policies to your IAM identities:

- AmazonBedrockFullAccess or AmazonBedrockStudioPermissionsBoundary
- AWSLambdaRole or AWSLambda_FullAccess

Useful links:

- [AWS API Keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)
- [Bedrock policies](https://docs.aws.amazon.com/bedrock/latest/userguide/security-iam-awsmanpol.html)
- [Lambda policies](https://docs.aws.amazon.com/lambda/latest/dg/permissions-user-function.html)
- [Flink AI: Create Model](https://docs.confluent.io/cloud/current/ai/ai-model-inference.html#create-an-ai-model)
- [Bedrock from Flink AI](https://docs.confluent.io/cloud/current/ai/ai-model-inference.html#aws-bedrock)

At the end of these steps, you should have:

- A *key* and a *secret* for Confluent Cloud
- A *public key* and a *private key* for MongoDB Atlas
- A *key*, a *secret* and a *token* for AWS.

At last, get your Atlas Organization ID from the Atlas UI.

![Atlas Organization ID](./assets/atlas-org-id.png)

## Run the Quickstart

### 1. Bring up the infrastructure

```sh
# Follow the prompts to enter your API keys
./deploy.sh
```

### 2. Bring down the infrastructure

```sh
./destroy.sh
```