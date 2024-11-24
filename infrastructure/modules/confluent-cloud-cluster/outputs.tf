output "clients_schema_registry_api_key" {
  value       = confluent_api_key.clients-schema-registry-api-key
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients_kafka_api_key" {
  value       = confluent_api_key.client-key
  description = "API Key for Kafka client"
  sensitive   = true
}

output "app_manager_flink_api_key" {
  value       = confluent_api_key.app-manager-flink-api-key
  description = "API Key for managing flink resources"
  sensitive   = true
}

output "schema_registry_url" {
  value       = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  description = "URL for the Schema Registry"
}

output "bootstrap_servers" {
  value       = replace(confluent_kafka_cluster.standard.bootstrap_endpoint, "SASL_SSL://", "")
  description = "Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL_SSL:// prefix for ease of use."
}

output "flink_rest_endpoint" {
  value       = data.confluent_flink_region.main.rest_endpoint
  description = "Flink REST endpoint"
}

output "flink_environment_id" {
  value       = confluent_flink_compute_pool.main.environment[0].id
  description = "Confluent Cloud Flink Environment ID"
}

output "organization_id" {
  value       = data.confluent_organization.main.id
  description = "Confluent Cloud Organization ID"
}