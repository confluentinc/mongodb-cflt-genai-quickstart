# confluent-cloud-cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 2.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | ~> 2.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [confluent_api_key.app-manager-flink-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.client_key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.clients-schema-registry-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_environment.staging](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/environment) | resource |
| [confluent_flink_compute_pool.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_compute_pool) | resource |
| [confluent_flink_statement.create-models](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.create-tables](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.insert-data](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_kafka_acl.app-client-describe-on-cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-read-on-target-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-write-to-data-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_cluster.standard](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_cluster) | resource |
| [confluent_role_binding.app-manager-assigner](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.app-manager-flink-developer](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-kafka-cluster-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-schema-registry-developer-write](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.statements-runner-environment-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_service_account.app-manager](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.clients](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.statements-runner](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_environment.staging](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/environment) | data source |
| [confluent_flink_region.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/flink_region) | data source |
| [confluent_organization.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/organization) | data source |
| [confluent_schema_registry_cluster.essentials](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/schema_registry_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_environment"></a> [confluent\_cloud\_environment](#input\_confluent\_cloud\_environment) | Whether to create a new Confluent Cloud environment or not. Once the environment is created | <pre>object({<br>    enable_creation = bool<br>    name            = string<br>  })</pre> | n/a | yes |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | n/a | yes |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | n/a | yes |
| <a name="input_create_model_sql_files"></a> [create\_model\_sql\_files](#input\_create\_model\_sql\_files) | The set of SQL files that contain the create model statements | `set(string)` | `[]` | no |
| <a name="input_create_table_sql_files"></a> [create\_table\_sql\_files](#input\_create\_table\_sql\_files) | The set of SQL files that contain the create table statements | `set(string)` | `[]` | no |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A random string we will be appending to resources like environment, api keys, etc. to make them unique | `string` | n/a | yes |
| <a name="input_insert_data_sql_files"></a> [insert\_data\_sql\_files](#input\_insert\_data\_sql\_files) | The set of SQL files that contain the insert data statements | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_servers"></a> [bootstrap\_servers](#output\_bootstrap\_servers) | Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL\_SSL:// prefix for ease of use. |
| <a name="output_clients-kafka-api-key"></a> [clients-kafka-api-key](#output\_clients-kafka-api-key) | API Key for Kafka client |
| <a name="output_clients-schema-registry-api-key"></a> [clients-schema-registry-api-key](#output\_clients-schema-registry-api-key) | API Key for Schema Registry client |
| <a name="output_schema_registry_url"></a> [schema\_registry\_url](#output\_schema\_registry\_url) | URL for the Schema Registry |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
