output "clients-schema-registry-api-key" {
  value       = confluent_api_key.clients-schema-registry-api-key
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients-kafka-api-key" {
  value       = confluent_api_key.client_key
  description = "API Key for Kafka client"
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