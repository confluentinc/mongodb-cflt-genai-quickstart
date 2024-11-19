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
  description = "Whether to create a new Confluent Cloud environment or not. Once the environment is created "
  type = object({
    enable_creation = bool
    name            = string
  })
}
