module "confluent_cloud_cluster" {
  source                           = "./modules/confluent-cloud-cluster"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider
  confluent_cloud_environment = {
    enable_creation = var.confluent_cloud_create_environment
    name            = var.confluent_cloud_environmant_name
  }
  create_model_sql_files = local.create_model_sql_files
  insert_data_sql_files  = local.insert_data_sql_files
  create_table_sql_files = local.create_table_sql_files
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