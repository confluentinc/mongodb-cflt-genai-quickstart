# backend

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.76.0 |

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
| [aws_secretsmanager_secret.confluent_cloud_genai_demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.confluent_cloud_genai_demo_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_servers"></a> [bootstrap\_servers](#input\_bootstrap\_servers) | The bootstrap servers for the Kafka clients to connect to the Kafka cluster | `string` | n/a | yes |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A random string we will be appending to resources like environment, api keys, etc. to make them unique | `string` | n/a | yes |
| <a name="input_kafka_api_key"></a> [kafka\_api\_key](#input\_kafka\_api\_key) | The API key for the Kafka client | <pre>object({<br>    id     = string<br>    secret = string<br>  })</pre> | n/a | yes |
| <a name="input_schema_registry_api_key"></a> [schema\_registry\_api\_key](#input\_schema\_registry\_api\_key) | The API key for the Schema Registry | <pre>object({<br>    id     = string<br>    secret = string<br>  })</pre> | n/a | yes |
| <a name="input_schema_registry_url"></a> [schema\_registry\_url](#input\_schema\_registry\_url) | The URL for the Schema Registry | `string` | n/a | yes |
| <a name="input_system_architecture"></a> [system\_architecture](#input\_system\_architecture) | The target OS architecture for the Lambda function to run on | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_websocket_endpoint"></a> [websocket\_endpoint](#output\_websocket\_endpoint) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
