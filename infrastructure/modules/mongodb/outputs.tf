output "host" {
  value       = split("://", mongodbatlas_cluster.cluster.srv_address)[1]
  description = "Cluster host address"
}

output "connection_user" {
  value       = mongodbatlas_database_user.default.username
  description = "database user provisioned"
}

output "connection_password" {
  value       = mongodbatlas_database_user.default.password
  sensitive   = true
  description = "database pwd provisioned"
}

output "project_id" {
  value       = mongodbatlas_project.test.id
  description = "MongoDB Atlas Project ID"
}

output "collection" {
  value       = var.mongodbatlas_collection
  description = "MongoDB Atlas Collection"
}

output "database" {
  value       = var.mongodbatlas_database
  description = "MongoDB Atlas Database"
}

output "cluster" {
  value       = var.mongodbatlas_cluster
  description = "MongoDB Atlas Cluster"
}
