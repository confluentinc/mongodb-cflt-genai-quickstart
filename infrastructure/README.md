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
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | 2.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.75.0 |
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 2.5.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_websocket_api"></a> [aws\_websocket\_api](#module\_aws\_websocket\_api) | terraform-aws-modules/apigateway-v2/aws | n/a |
| <a name="module_lambda_trigger_connections_api"></a> [lambda\_trigger\_connections\_api](#module\_lambda\_trigger\_connections\_api) | terraform-aws-modules/lambda/aws | ~> 4.0 |
| <a name="module_websocket_chat_api_lambda"></a> [websocket\_chat\_api\_lambda](#module\_websocket\_chat\_api\_lambda) | terraform-aws-modules/lambda/aws | ~> 4.0 |
| <a name="module_websocket_chat_api_lambda_layer"></a> [websocket\_chat\_api\_lambda\_layer](#module\_websocket\_chat\_api\_lambda\_layer) | terraform-aws-modules/lambda/aws | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_s3_bucket.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_website_configuration.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_secretsmanager_secret.confluent_cloud_genai_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.confluent_cloud_genai_demo_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [confluent_api_key.app-manager-flink-api-key](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/api_key) | resource |
| [confluent_api_key.client_key](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/api_key) | resource |
| [confluent_api_key.clients-schema-registry-api-key](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/api_key) | resource |
| [confluent_environment.staging](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/environment) | resource |
| [confluent_flink_compute_pool.main](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/flink_compute_pool) | resource |
| [confluent_flink_statement.create-models](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.create-tables](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.insert-data](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/flink_statement) | resource |
| [confluent_kafka_acl.app-client-describe-on-cluster](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-read-on-target-topic](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-write-to-data-topics](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/kafka_acl) | resource |
| [confluent_kafka_cluster.standard](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/kafka_cluster) | resource |
| [confluent_role_binding.app-manager-assigner](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/role_binding) | resource |
| [confluent_role_binding.app-manager-flink-developer](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-kafka-cluster-admin](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-schema-registry-developer-write](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/role_binding) | resource |
| [confluent_role_binding.statements-runner-environment-admin](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/role_binding) | resource |
| [confluent_service_account.app-manager](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/service_account) | resource |
| [confluent_service_account.clients](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/service_account) | resource |
| [confluent_service_account.statements-runner](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/resources/service_account) | resource |
| [null_resource.frontend_build_and_deploy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.env_display_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [confluent_environment.staging](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/data-sources/environment) | data source |
| [confluent_flink_region.main](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/data-sources/flink_region) | data source |
| [confluent_organization.main](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/data-sources/organization) | data source |
| [confluent_schema_registry_cluster.essentials](https://registry.terraform.io/providers/confluentinc/confluent/2.5.0/docs/data-sources/schema_registry_cluster) | data source |
| [external_external.system_architecture](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the infrastructure | `string` | `"us-east-1"` | no |
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | `"us-east-1"` | no |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | `"AWS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_cloudfront_domain-name"></a> [cloudfront\_domain-name](#output\_cloudfront\_domain-name) | n/a |
| <a name="output_resource-ids"></a> [resource-ids](#output\_resource-ids) | The IDs of the resources created by this module. This output is sensitive and will not be displayed in the plan. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
