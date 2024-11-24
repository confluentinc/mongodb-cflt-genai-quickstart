variable "mongodbatlas_org_id" {
  description = "Organization ID"
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

variable "mongodbatlas_cloud_provider" {
  description = "Cloud provider"
  type        = string
}

variable "mongodbatlas_cloud_region" {
  description = "Cloud provider region name (note that MongoDB values are different than usual Cloud provider ones)"
  type        = string
}

variable "mongodbatlas_project" {
  description = "Atlas project"
  type        = string
}

variable "mongodbatlas_cluster" {
  description = "Atlas cluster"
  type        = string
}

variable "mongodbatlas_database" {
  description = "Atlas database"
  type        = string
}

variable "mongodbatlas_collection" {
  description = "Atlas collection"
  type        = string
}
