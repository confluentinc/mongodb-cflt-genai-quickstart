# Infrastructure

This directory contains the Terraform configuration for the Confluent Cloud infrastructure. 

To run, you need to have:
- a Confluent Cloud API Key and Secret. See https://www.confluent.io/blog/confluent-terraform-provider-intro/#api-key for more details.
- a MongoDB Atlas API Key and Secret. See TODO

## Terraform commands 

### Plan

```bash
terraform plan --var-file terraform.tfvars
```

### Apply

```bash
terraform apply --var-file terraform.tfvars
```

### Output

```bash
terraform output resource-ids
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.76.0 |
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 2.11.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | 1.21.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | 1.21.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend"></a> [backend](#module\_backend) | ./modules/backend | n/a |
| <a name="module_confluent_cloud_cluster"></a> [confluent\_cloud\_cluster](#module\_confluent\_cloud\_cluster) | ./modules/confluent-cloud-cluster | n/a |
| <a name="module_frontend"></a> [frontend](#module\_frontend) | ./modules/frontend | n/a |
| <a name="module_mongodb"></a> [mongodb](#module\_mongodb) | ./modules/mongodb | n/a |

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_search_index.search-vector](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.4/docs/resources/search_index) | resource |
| [random_id.env_display_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [external_external.system_architecture](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the infrastructure | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_name"></a> [confluent\_cloud\_environment\_name](#input\_confluent\_cloud\_environment\_name) | The name of the Confluent Cloud environment to create | `string` | `"genai-quickstart"` | no |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | n/a | yes |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | `"AWS"` | no |
| <a name="input_connections_api_topics_info"></a> [connections\_api\_topics\_info](#input\_connections\_api\_topics\_info) | The relevant kafka topics that the connections API lambda function will interact with. `input_topic` is what the lambda function will consume from. | <pre>object({<br/>    input_topic = string<br/>  })</pre> | <pre>{<br/>  "input_topic": "chat_output"<br/>}</pre> | no |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A string that will be appended to different resources to make them unique. If not provided, a random string will be generated. | `string` | `null` | no |
| <a name="input_mongodbatlas_cloud_provider"></a> [mongodbatlas\_cloud\_provider](#input\_mongodbatlas\_cloud\_provider) | The cloud provider of MongoDB Atlas | `string` | `"AWS"` | no |
| <a name="input_mongodbatlas_cloud_region"></a> [mongodbatlas\_cloud\_region](#input\_mongodbatlas\_cloud\_region) | The region of MongoDB Atlas | `string` | n/a | yes |
| <a name="input_mongodbatlas_cluster"></a> [mongodbatlas\_cluster](#input\_mongodbatlas\_cluster) | Atlas cluster | `string` | `"genai"` | no |
| <a name="input_mongodbatlas_collection"></a> [mongodbatlas\_collection](#input\_mongodbatlas\_collection) | Atlas collection | `string` | `"products_summarized_with_embeddings"` | no |
| <a name="input_mongodbatlas_database"></a> [mongodbatlas\_database](#input\_mongodbatlas\_database) | Atlas database | `string` | `"genai"` | no |
| <a name="input_mongodbatlas_org_id"></a> [mongodbatlas\_org\_id](#input\_mongodbatlas\_org\_id) | Organization ID | `string` | n/a | yes |
| <a name="input_mongodbatlas_private_key"></a> [mongodbatlas\_private\_key](#input\_mongodbatlas\_private\_key) | Private API key to authenticate to Atlas | `string` | n/a | yes |
| <a name="input_mongodbatlas_project"></a> [mongodbatlas\_project](#input\_mongodbatlas\_project) | Atlas project | `string` | `"GenAI-Quickstart"` | no |
| <a name="input_mongodbatlas_public_key"></a> [mongodbatlas\_public\_key](#input\_mongodbatlas\_public\_key) | Public API key to authenticate to Atlas | `string` | n/a | yes |
| <a name="input_path_to_flink_sql_create_model_statements"></a> [path\_to\_flink\_sql\_create\_model\_statements](#input\_path\_to\_flink\_sql\_create\_model\_statements) | The path to the SQL statements that will be used to create model in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_create_table_statements"></a> [path\_to\_flink\_sql\_create\_table\_statements](#input\_path\_to\_flink\_sql\_create\_table\_statements) | The path to the SQL statements that will be used to create tables in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_insert_statements"></a> [path\_to\_flink\_sql\_insert\_statements](#input\_path\_to\_flink\_sql\_insert\_statements) | The path to the SQL statements that will be used to insert data in Flink | `string` | `null` | no |
| <a name="input_vectorsearch_topics_info"></a> [vectorsearch\_topics\_info](#input\_vectorsearch\_topics\_info) | The relevant kafka topics that the vectorsearch lambda function will connect to | <pre>object({<br/>    input_topic  = string<br/>    output_topic = string<br/>  })</pre> | <pre>{<br/>  "input_topic": "chat_input_embeddings",<br/>  "output_topic": "chat_input_with_products"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_servers"></a> [bootstrap\_servers](#output\_bootstrap\_servers) | Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL\_SSL:// prefix for ease of use. |
| <a name="output_clients_kafka_api_key"></a> [clients\_kafka\_api\_key](#output\_clients\_kafka\_api\_key) | API Key for Kafka client |
| <a name="output_clients_schema_registry_api_key"></a> [clients\_schema\_registry\_api\_key](#output\_clients\_schema\_registry\_api\_key) | API Key for Schema Registry client |
| <a name="output_flink_api_key"></a> [flink\_api\_key](#output\_flink\_api\_key) | API Key for managing flink resources |
| <a name="output_flink_environment_id"></a> [flink\_environment\_id](#output\_flink\_environment\_id) | Confluent Cloud Flink Environment ID |
| <a name="output_flink_rest_endpoint"></a> [flink\_rest\_endpoint](#output\_flink\_rest\_endpoint) | Flink REST endpoint |
| <a name="output_frontend_url"></a> [frontend\_url](#output\_frontend\_url) | n/a |
| <a name="output_mongodb_db_password"></a> [mongodb\_db\_password](#output\_mongodb\_db\_password) | n/a |
| <a name="output_mongodb_db_user"></a> [mongodb\_db\_user](#output\_mongodb\_db\_user) | n/a |
| <a name="output_mongodb_host"></a> [mongodb\_host](#output\_mongodb\_host) | n/a |
| <a name="output_schema_registry_url"></a> [schema\_registry\_url](#output\_schema\_registry\_url) | URL for the Schema Registry |
| <a name="output_websocket_endpoint"></a> [websocket\_endpoint](#output\_websocket\_endpoint) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
