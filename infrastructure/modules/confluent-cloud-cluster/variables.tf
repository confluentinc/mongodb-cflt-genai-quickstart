variable "confluent_cloud_region" {
  description = "The region of Confluent Cloud Network"
  type        = string
}

variable "confluent_cloud_service_provider" {
  description = "The cloud provider of Confluent Cloud Network"
  type        = string
}

variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}

variable "create_table_sql_files" {
  description = "The set of SQL files that contain the create table statements"
  type        = set(string)
  default     = []
}

variable "create_model_sql_files" {
  description = "The set of SQL files that contain the create model statements"
  type        = set(string)
  default     = []
}

variable "insert_data_sql_files" {
  description = "The set of SQL files that contain the insert data statements"
  type        = set(string)
  default     = []
}

variable "confluent_cloud_environment" {
  description = "The environment configuration for Confluent Cloud"
  type = object({
    name = string
  })
}

variable "mongodb_user" {
  description = ""
  type        = string
}
variable "mongodb_password" {
  description = ""
  type        = string
}
variable "mongodb_host" {
  description = ""
  type        = string
}

variable "mongodbatlas_public_key" {
  description = "Public API key to authenticate to Atlas"
  type        = string
}

variable "mongodbatlas_private_key" {
  description = "Private API key to authenticate to Atlas"
  type        = string
  sensitive   = true
}

variable "mongodbatlas_database" {
  description = "Atlas database"
  type        = string
  default     = "genai"
}

variable "mongodbatlas_collection" {
  description = "Atlas collection"
  type        = string
  default     = "all_insurance_products_embeddings"
}
