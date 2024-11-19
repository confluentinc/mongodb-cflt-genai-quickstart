# Infrastructure

This directory contains the Terraform configuration for the Confluent Cloud infrastructure. To run, you need to have the Confluent Cloud API Key and Secret. 
See https://www.confluent.io/blog/confluent-terraform-provider-intro/#api-key for more details.

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
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 2.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend"></a> [backend](#module\_backend) | ./modules/backend | n/a |
| <a name="module_confluent_cloud_cluster"></a> [confluent\_cloud\_cluster](#module\_confluent\_cloud\_cluster) | ./modules/confluent-cloud-cluster | n/a |
| <a name="module_frontend"></a> [frontend](#module\_frontend) | ./modules/frontend | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.env_display_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [external_external.system_architecture](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the infrastructure | `string` | `"us-east-1"` | no |
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_create_environment"></a> [confluent\_cloud\_create\_environment](#input\_confluent\_cloud\_create\_environment) | Whether to create a new Confluent Cloud environment or not. Once the environment is created, it will be used for the rest of the resources. | `bool` | n/a | yes |
| <a name="input_confluent_cloud_environmant_name"></a> [confluent\_cloud\_environmant\_name](#input\_confluent\_cloud\_environmant\_name) | The name of the Confluent Cloud environment to create | `string` | `"genai-demo"` | no |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | `"us-east-1"` | no |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | `"AWS"` | no |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A string that will be appended to different resources to make them unique. If not provided, a random string will be generated. | `string` | `null` | no |
| <a name="input_path_to_flink_sql_create_model_statements"></a> [path\_to\_flink\_sql\_create\_model\_statements](#input\_path\_to\_flink\_sql\_create\_model\_statements) | The path to the SQL statements that will be used to create model in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_create_table_statements"></a> [path\_to\_flink\_sql\_create\_table\_statements](#input\_path\_to\_flink\_sql\_create\_table\_statements) | The path to the SQL statements that will be used to create tables in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_insert_statements"></a> [path\_to\_flink\_sql\_insert\_statements](#input\_path\_to\_flink\_sql\_insert\_statements) | The path to the SQL statements that will be used to insert data in Flink | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_servers"></a> [bootstrap\_servers](#output\_bootstrap\_servers) | Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL\_SSL:// prefix for ease of use. |
| <a name="output_clients-kafka-api-key"></a> [clients-kafka-api-key](#output\_clients-kafka-api-key) | API Key for Kafka client |
| <a name="output_clients-schema-registry-api-key"></a> [clients-schema-registry-api-key](#output\_clients-schema-registry-api-key) | API Key for Schema Registry client |
| <a name="output_frontend_url"></a> [frontend\_url](#output\_frontend\_url) | n/a |
| <a name="output_schema_registry_url"></a> [schema\_registry\_url](#output\_schema\_registry\_url) | URL for the Schema Registry |
| <a name="output_websocket_endpoint"></a> [websocket\_endpoint](#output\_websocket\_endpoint) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
