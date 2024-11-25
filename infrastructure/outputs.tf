output "clients_schema_registry_api_key" {
  value       = module.confluent_cloud_cluster.clients_schema_registry_api_key
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients_kafka_api_key" {
  value       = module.confluent_cloud_cluster.clients_kafka_api_key
  description = "API Key for Kafka client"
  sensitive   = true
}

output "schema_registry_url" {
  value       = module.confluent_cloud_cluster.schema_registry_url
  description = "URL for the Schema Registry"
}

output "bootstrap_servers" {
  value       = module.confluent_cloud_cluster.bootstrap_servers
  description = "Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL_SSL:// prefix for ease of use."
}

output "flink_api_key" {
  value       = module.confluent_cloud_cluster.app_manager_flink_api_key
  description = "API Key for managing flink resources"
  sensitive   = true
}

output "flink_rest_endpoint" {
  value       = module.confluent_cloud_cluster.flink_rest_endpoint
  description = "Flink REST endpoint"
}

output "flink_environment_id" {
  value       = module.confluent_cloud_cluster.flink_environment_id
  description = "Confluent Cloud Flink Environment ID"
}

output "frontend_url" {
  value = "https://${module.frontend.frontend_url}"
}

output "websocket_endpoint" {
  value = module.backend.websocket_endpoint
}

output "mongodb_host" {
  value = module.mongodb.host
}

output "mongodb_db_user" {
  value = module.mongodb.connection_user
}

output "mongodb_db_password" {
  value     = module.mongodb.connection_password
  sensitive = true
}