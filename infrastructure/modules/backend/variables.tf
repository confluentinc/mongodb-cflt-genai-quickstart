variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}

variable "system_architecture" {
  description = "The target OS architecture for the Lambda function to run on"
  type        = string
  validation {
    condition     = var.system_architecture == "arm64" || var.system_architecture == "x86_64"
    error_message = "The system architecture must be either arm64 or x86_64"
  }
}

variable "schema_registry_api_key" {
  description = "The API key for the Schema Registry"
  type = object({
    id     = string
    secret = string
  })
}

variable "schema_registry_url" {
  description = "The URL for the Schema Registry"
  type        = string
}

variable "bootstrap_servers" {
  description = "The bootstrap servers for the Kafka clients to connect to the Kafka cluster"
  type        = string
  validation {
    condition     = !can(regex("^SASL_SSL://", var.bootstrap_servers))
    error_message = "The bootstrap servers should not start with SASL_SSL://"
  }
}

variable "kafka_api_key" {
  description = "The API key for the Kafka client"
  type = object({
    id     = string
    secret = string
  })
}