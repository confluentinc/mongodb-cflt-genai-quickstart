output "clients-schema-registry-api-key" {
  value       = module.confluent_cloud_cluster.clients-schema-registry-api-key
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients-kafka-api-key" {
  value       = module.confluent_cloud_cluster.clients-kafka-api-key
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

output "frontend_url" {
  value = module.frontend.frontend_url
}

output "websocket_endpoint" {
  value = module.backend.websocket_endpoint
}