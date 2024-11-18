output "resource-ids" {
  value = <<-EOT
  Websocket URL: ${module.aws_websocket_api.api_endpoint}/${module.aws_websocket_api.stage_id}

  Environment ID:   ${confluent_environment.staging.id}
  Kafka Cluster ID: ${confluent_kafka_cluster.standard.id}
  Flink Cluster ID: ${data.confluent_flink_region.main.id}
  Kafka Cluster Bootstrap URL: ${replace(confluent_kafka_cluster.standard.bootstrap_endpoint, "SASL_SSL://", "")}
  Schema Registry URL: ${data.confluent_schema_registry_cluster.essentials.rest_endpoint}
  Flink Cluster URL: ${data.confluent_flink_region.main.rest_endpoint}

  Service Accounts and their Kafka API Keys (API Keys inherit the permissions granted to the owner):
  ${confluent_service_account.app-manager.display_name}:                     ${confluent_service_account.app-manager.id}
  ${confluent_service_account.app-manager.display_name}'s Flink API Key:     "${confluent_api_key.app-manager-flink-api-key.id}"
  ${confluent_service_account.app-manager.display_name}'s Flink API Secret:  "${confluent_api_key.app-manager-flink-api-key.secret}"

  ${confluent_service_account.clients.display_name}:                    ${confluent_service_account.clients.id}
  ${confluent_service_account.clients.display_name}'s Kafka API Key:    "${confluent_api_key.client_key.id}"
  ${confluent_service_account.clients.display_name}'s Kafka API Secret: "${confluent_api_key.client_key.secret}"

  ${confluent_service_account.clients.display_name}:                    ${confluent_service_account.clients.id}
  ${confluent_service_account.clients.display_name}'s Schema Registry API Key:    "${confluent_api_key.clients-schema-registry-api-key.id}"
  ${confluent_service_account.clients.display_name}'s Schema Registry API Secret: "${confluent_api_key.clients-schema-registry-api-key.secret}"
  EOT

  description = "The IDs of the resources created by this module. This output is sensitive and will not be displayed in the plan."
  sensitive   = true
}