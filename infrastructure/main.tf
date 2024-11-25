module "mongodb" {
  source                      = "./modules/mongodb"
  mongodbatlas_public_key     = var.mongodbatlas_public_key
  mongodbatlas_private_key    = var.mongodbatlas_private_key
  mongodbatlas_database       = var.mongodbatlas_database
  mongodbatlas_collection     = var.mongodbatlas_collection
  mongodbatlas_org_id         = var.mongodbatlas_org_id
  mongodbatlas_cluster        = var.mongodbatlas_cluster
  mongodbatlas_project        = var.mongodbatlas_project
  mongodbatlas_cloud_provider = var.mongodbatlas_cloud_provider
  mongodbatlas_cloud_region   = replace(upper(var.mongodbatlas_cloud_region), "-", "_")
  providers = {
    mongodbatlas = mongodbatlas
  }
}


module "confluent_cloud_cluster" {
  source                           = "./modules/confluent-cloud-cluster"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider
  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }
  create_model_sql_files = local.create_model_sql_files
  insert_data_sql_files  = local.insert_data_sql_files
  create_table_sql_files = local.create_table_sql_files

  mongodb_user            = module.mongodb.connection_user
  mongodb_password        = module.mongodb.connection_password
  mongodb_host            = module.mongodb.host
  mongodbatlas_database   = var.mongodbatlas_database
  mongodbatlas_collection = var.mongodbatlas_collection

  depends_on = [
    module.mongodb
  ]
}

resource "mongodbatlas_search_index" "search-vector" {
  name            = "${var.mongodbatlas_collection}-vector"
  project_id      = module.mongodb.project_id
  cluster_name    = var.mongodbatlas_cluster
  collection_name = var.mongodbatlas_collection
  database        = var.mongodbatlas_database
  type            = "vectorSearch"
  depends_on = [
    module.confluent_cloud_cluster
  ]
  fields = <<-EOF
[{
      "type": "vector",
      "path": "embeddings",
      "numDimensions": 1024,
      "similarity": "euclidean"
}]
EOF
}

module "backend" {
  source                 = "./modules/backend"
  env_display_id_postfix = local.env_display_id_postfix
  bootstrap_servers      = module.confluent_cloud_cluster.bootstrap_servers
  kafka_api_key = {
    id     = module.confluent_cloud_cluster.clients_kafka_api_key.id
    secret = module.confluent_cloud_cluster.clients_kafka_api_key.secret
  }
  schema_registry_url = module.confluent_cloud_cluster.schema_registry_url
  schema_registry_api_key = {
    id     = module.confluent_cloud_cluster.clients_schema_registry_api_key.id
    secret = module.confluent_cloud_cluster.clients_schema_registry_api_key.secret
  }
  system_architecture = local.system_architecture

  connections_api_topics_info = var.connections_api_topics_info
  vectorsearch_topics_info    = var.vectorsearch_topics_info

  mongodb_db_user = {
    id     = module.mongodb.connection_user
    secret = module.mongodb.connection_password
  }

  mongodb_vectorsearch_info = {
    collection_name = module.mongodb.collection
    index_name      = mongodbatlas_search_index.search-vector.name
    field_path      = "embeddings"
  }

  mongodb_db_info = {
    host    = module.mongodb.host
    db_name = module.mongodb.database
  }

  depends_on = [
    module.confluent_cloud_cluster
  ]
}

module "frontend" {
  source                 = "./modules/frontend"
  env_display_id_postfix = local.env_display_id_postfix
  websocket_endpoint     = module.backend.websocket_endpoint
  depends_on = [
    module.backend
  ]
}