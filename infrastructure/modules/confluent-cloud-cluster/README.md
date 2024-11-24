# confluent-cloud-cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | ~> 2.11.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [confluent_api_key.app-manager-flink-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.client-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.clients-schema-registry-api-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_api_key.mongodb-sink-connector-key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/api_key) | resource |
| [confluent_connector.mongo-db-sink](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/connector) | resource |
| [confluent_environment.staging](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/environment) | resource |
| [confluent_flink_compute_pool.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_compute_pool) | resource |
| [confluent_flink_statement.create-models](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.create-tables](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_flink_statement.insert-data](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/flink_statement) | resource |
| [confluent_kafka_acl.app-client-describe-on-cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-read-on-target-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.app-client-write-to-data-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-create-on-dlq-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-create-on-error-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-create-on-success-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-describe-on-cluster](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-read-on-connect-lcc-group](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-read-on-target-topic](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-write-on-dlq-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-write-on-error-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_acl.mongodb-sink-connector-write-on-success-lcc-topics](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_acl) | resource |
| [confluent_kafka_cluster.standard](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/kafka_cluster) | resource |
| [confluent_role_binding.app-manager-assigner](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.app-manager-flink-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.app-manager-flink-developer](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-kafka-cluster-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.client-schema-registry-developer-write](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.mongodb-sink-connector-cluster-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_role_binding.statements-runner-environment-admin](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/role_binding) | resource |
| [confluent_service_account.app-manager](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.clients](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.mongodb-sink-connector](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [confluent_service_account.statements-runner](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/service_account) | resource |
| [null_resource.create-flink-bedrock-connections](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [confluent_flink_region.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/flink_region) | data source |
| [confluent_organization.main](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/organization) | data source |
| [confluent_schema_registry_cluster.essentials](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/data-sources/schema_registry_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_environment"></a> [confluent\_cloud\_environment](#input\_confluent\_cloud\_environment) | The environment configuration for Confluent Cloud | <pre>object({<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | n/a | yes |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | n/a | yes |
| <a name="input_create_model_sql_files"></a> [create\_model\_sql\_files](#input\_create\_model\_sql\_files) | The set of SQL files that contain the create model statements | `set(string)` | `[]` | no |
| <a name="input_create_table_sql_files"></a> [create\_table\_sql\_files](#input\_create\_table\_sql\_files) | The set of SQL files that contain the create table statements | `set(string)` | `[]` | no |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A random string we will be appending to resources like environment, api keys, etc. to make them unique | `string` | n/a | yes |
| <a name="input_insert_data_sql_files"></a> [insert\_data\_sql\_files](#input\_insert\_data\_sql\_files) | The set of SQL files that contain the insert data statements | `set(string)` | `[]` | no |
| <a name="input_mongodb_host"></a> [mongodb\_host](#input\_mongodb\_host) | The mongodb cluster host | `string` | n/a | yes |
| <a name="input_mongodb_password"></a> [mongodb\_password](#input\_mongodb\_password) | The MongoDB host. Use a hostname address and not a full URL. For example: cluster4-r5q3r7.gcp.mongodb.net. The hostname address must provide a service record (SRV). A standard connection string does not work. | `string` | n/a | yes |
| <a name="input_mongodb_user"></a> [mongodb\_user](#input\_mongodb\_user) | MongoDB Atlas connection user. | `string` | n/a | yes |
| <a name="input_mongodbatlas_collection"></a> [mongodbatlas\_collection](#input\_mongodbatlas\_collection) | Collection name to write to. If the connector is sinking data from multiple topics, this is the default collection the topics are mapped to. | `string` | n/a | yes |
| <a name="input_mongodbatlas_database"></a> [mongodbatlas\_database](#input\_mongodbatlas\_database) | MongoDB Atlas database name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_manager_flink_api_key"></a> [app\_manager\_flink\_api\_key](#output\_app\_manager\_flink\_api\_key) | API Key for managing flink resources |
| <a name="output_bootstrap_servers"></a> [bootstrap\_servers](#output\_bootstrap\_servers) | Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL\_SSL:// prefix for ease of use. |
| <a name="output_clients_kafka_api_key"></a> [clients\_kafka\_api\_key](#output\_clients\_kafka\_api\_key) | API Key for Kafka client |
| <a name="output_clients_schema_registry_api_key"></a> [clients\_schema\_registry\_api\_key](#output\_clients\_schema\_registry\_api\_key) | API Key for Schema Registry client |
| <a name="output_flink_environment_id"></a> [flink\_environment\_id](#output\_flink\_environment\_id) | Confluent Cloud Flink Environment ID |
| <a name="output_flink_rest_endpoint"></a> [flink\_rest\_endpoint](#output\_flink\_rest\_endpoint) | Flink REST endpoint |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | Confluent Cloud Organization ID |
| <a name="output_schema_registry_url"></a> [schema\_registry\_url](#output\_schema\_registry\_url) | URL for the Schema Registry |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
