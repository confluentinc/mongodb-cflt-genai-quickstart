# Developer Guide

A guide for developers to understand the project structure and how to contribute to the project.

## 🚀 Project Structure

```text
. # root of the project
├── assets # images and other assets for the README
├── frontend # Frontend project for the chatbot. This is what will be deployed to s3 and exposed via cloudfront
└── infrastructure # terraform to deploy the infrastructure
    ├── modules
    │     ├── backend # websocket backend & lambdas for the chatbot
    │     │     └── functions # lambda functions
    │     │     └── search # vector search lambda function
    │     ├── confluent-cloud-cluster # confluent cloud infra. i.e. kafka, flink, schema registry, etc.
    │         └── scripts # scripts to assist with building and deploying confluent cloud cluster resources
    │     └── frontend # s3 bucket and cloudfront distribution
    │         └── scripts # scripts to assist with building and deploying the frontend
    ├── scripts # scripts to assist with deploying the infrastructure
    └── statements # sql statements to register against a flink cluster
        ├── create-models
        ├── create-tables
        └── insert
```

## 🛠️ Working with terraform

Follow the instructions in the [README](../README.md) to setup your api keys and other environment variables. Once you have your variables all set up, you can run terraform commands via docker compose to plan, apply, and destroy the infrastructure as needed.

### Example Commands

#### Destroy Infrastructure

```bash
# variables.tfvars is a file that is mounted onto the containers working directory. you can find this file within the infrastructure directory locally.
docker compose run --rm terraform destroy -auto-approve -var-file variables.tfvars
```

#### Apply Infrastructure

```bash
# variables.tfvars is a file that is mounted onto the containers working directory. you can find this file within the infrastructure directory locally.
docker compose run --rm terraform apply -auto-approve -var-file variables.tfvars
```

### Plan Infrastructure

```bash
# variables.tfvars is a file that is mounted onto the containers working directory. you can find this file within the infrastructure directory locally.
docker compose run --rm terraform plan -var-file variables.tfvars
```

## Working with the Frontend

The frontend is a astro project that is built and deployed to an s3 bucket and made available via cloudfront. Once you have the infrastructure deployed, a .env file will be generated in the frontend directory. This file will contain the websocket url that the frontend will use for its communication with the backend. To develop the frontend locally, you can run the following commands:

```bash
cd frontend
npm i # if you haven't already
npm run dev
```

This will allow you to work on the frontend while working against the backend thats deployed in the cloud.