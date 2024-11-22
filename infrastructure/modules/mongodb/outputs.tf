output "host" {
  value       = split("://", mongodbatlas_cluster.cluster-test.srv_address)[1]
  description = "Cluster host address"
}

output "connection_user" {
  value = mongodbatlas_database_user.default.username
  description = "user provisioned"
}

output "connection_password" {
  value = mongodbatlas_database_user.default.password
  sensitive = true
  description = "pwd provisioned"
}
