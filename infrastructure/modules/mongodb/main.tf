resource "mongodbatlas_project" "test" {
  name   = var.mongodbatlas_project
  org_id = var.mongodbatlas_org_id
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.test.id
  name       = var.mongodbatlas_cluster

  # Provider Settings for Free tier
  provider_name               = "TENANT"
  backing_provider_name       = var.mongodbatlas_cloud_provider
  provider_region_name        = var.mongodbatlas_cloud_region
  provider_instance_size_name = "M0"
}

resource "random_password" "dbuser" {
  length  = 16
  special = false
}

resource "random_string" "dbuser" {
  length  = 8
  special = false
}

resource "mongodbatlas_database_user" "default" {
  project_id         = mongodbatlas_project.test.id
  username           = random_string.dbuser.result
  password           = random_password.dbuser.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.mongodbatlas_database
  }
}

resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.test.id
  cidr_block = "0.0.0.0/0"
  comment    = "IP Address for accessing the cluster"
}

