variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_region" {
  description = "The region of Confluent Cloud Network"
  type        = string
  default     = "us-east-1"
}

variable "confluent_cloud_service_provider" {
  description = "The cloud provider of Confluent Cloud Network"
  type        = string
  default     = "AWS"
}

variable "aws_region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "env_display_id_postfix" {
  description = "A string that will be appended to different resources to make them unique. If not provided, a random string will be generated."
  type        = string
  default     = null
  nullable    = true
}

variable "confluent_cloud_create_environment" {
  description = "Whether to create a new Confluent Cloud environment or not. Once the environment is created, it will be used for the rest of the resources."
  type        = bool
}

variable "confluent_cloud_environmant_name" {
  description = "The name of the Confluent Cloud environment to create"
  type        = string
  default     = "genai-demo"
}

variable "path_to_flink_sql_create_table_statements" {
  description = "The path to the SQL statements that will be used to create tables in Flink"
  type        = string
  default     = null
  nullable    = true
}

variable "path_to_flink_sql_create_model_statements" {
  description = "The path to the SQL statements that will be used to create model in Flink"
  type        = string
  default     = null
  nullable    = true
}

variable "path_to_flink_sql_insert_statements" {
  description = "The path to the SQL statements that will be used to insert data in Flink"
  type        = string
  default     = null
  nullable    = true
}