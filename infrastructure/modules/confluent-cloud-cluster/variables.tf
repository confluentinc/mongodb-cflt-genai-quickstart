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
  description = "MongoDB Atlas connection user."
  type        = string
}
variable "mongodb_password" {
  description = "The MongoDB host. Use a hostname address and not a full URL. For example: cluster4-r5q3r7.gcp.mongodb.net. The hostname address must provide a service record (SRV). A standard connection string does not work."
  type        = string
}
variable "mongodb_host" {
  description = "The mongodb cluster host"
  type        = string
}

variable "mongodbatlas_database" {
  description = "MongoDB Atlas database name"
  type        = string
}

variable "mongodbatlas_collection" {
  description = "Collection name to write to. If the connector is sinking data from multiple topics, this is the default collection the topics are mapped to."
  type        = string
}
