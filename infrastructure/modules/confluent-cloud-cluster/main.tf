data "confluent_organization" "main" {}

# ------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------

resource "confluent_environment" "staging" {
  display_name = "${var.confluent_cloud_environment.name}-${var.env_display_id_postfix}"
  stream_governance {
    package = "ESSENTIALS"
  }

  lifecycle {
    # flip this to true to prevent the environment from being destroyed
    prevent_destroy = false
  }
}

# ------------------------------------------------------
# KAFKA
# ------------------------------------------------------

# In Confluent Cloud, an environment is mapped to a Flink catalog, and a Kafka cluster is mapped to a Flink database.
resource "confluent_kafka_cluster" "standard" {
  display_name = "genai-quickstart-${var.env_display_id_postfix}"
  availability = "SINGLE_ZONE"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  standard {}
  environment {
    id = confluent_environment.staging.id
  }
}

# ------------------------------------------------------
# Schema Registry
# ------------------------------------------------------
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_kafka_cluster.standard,
  ]
}

# ------------------------------------------------------
# FLINK
# ------------------------------------------------------

# https://docs.confluent.io/cloud/current/flink/get-started/quick-start-cloud-console.html#step-1-create-a-af-compute-pool
resource "confluent_flink_compute_pool" "main" {
  display_name = "genai-quickstart-flink-compute-pool-${var.env_display_id_postfix}"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  max_cfu      = 30
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_role_binding.statements-runner-environment-admin,
    confluent_role_binding.app-manager-assigner,
    confluent_role_binding.app-manager-flink-developer,
    confluent_api_key.app-manager-flink-api-key,
  ]
}

data "confluent_flink_region" "main" {
  cloud  = var.confluent_cloud_service_provider
  region = var.confluent_cloud_region
}

resource "confluent_flink_statement" "create-tables" {
  for_each = var.create_table_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath(each.value))
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}

# registers flink sql connections with bedrock. should be replaced when
# terraform provider supports managing flink sql connections
resource "null_resource" "create-flink-bedrock-connections" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/flink-connection-create.sh"
    environment = {
      FLINK_API_KEY       = confluent_api_key.app-manager-flink-api-key.id
      FLINK_API_SECRET    = confluent_api_key.app-manager-flink-api-key.secret
      FLINK_ENV_ID        = confluent_flink_compute_pool.main.environment[0].id
      FLINK_ORG_ID        = data.confluent_organization.main.id
      FLINK_REST_ENDPOINT = data.confluent_flink_region.main.rest_endpoint
      # the rest should be set by deploy.sh
    }
  }

  triggers = {
    # changes to the flink sql cluster will trigger the bedrock connections to be created
    flink_sql_cluster_id = confluent_flink_compute_pool.main.id
    # change if the script changes
    script = filesha256("${path.module}/scripts/flink-connection-create.sh")
  }
}

resource "confluent_flink_statement" "create-models" {
  for_each = var.create_model_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath(each.value))
  depends_on = [
    null_resource.create-flink-bedrock-connections
  ]
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}

resource "confluent_flink_statement" "insert-data" {
  for_each = var.insert_data_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }

  stopped   = false
  statement = file(abspath(each.value))

  depends_on = [
    confluent_flink_statement.create-tables,
    confluent_flink_statement.create-models
  ]
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}


# ------------------------------------------------------
# Sink Connector to MongoDB
# ------------------------------------------------------
resource "confluent_service_account" "mongodb-sink-connector" {
  display_name = "mongodb-sink-connector-${var.env_display_id_postfix}"
  description  = "Service account of the MongoDB Sink Connector"
}

# ------------------------------------------------------
# SERVICE ACCOUNTS
# ------------------------------------------------------

// Service account for kafka clients that will be used to produce and consume messages
resource "confluent_service_account" "clients" {
  display_name = "client-sa-${var.env_display_id_postfix}"
  description  = "Service account for clients"
}

// Service account to perform a task within Confluent Cloud, such as executing a Flink statement
resource "confluent_service_account" "statements-runner" {
  display_name = "statements-runner-sa-${var.env_display_id_postfix}"
  description  = "Service account for running Flink Statements in the Kafka cluster"
}

// Service account that owns Flink API Key
resource "confluent_service_account" "app-manager" {
  display_name = "app-manager-sa-${var.env_display_id_postfix}"
  description  = "Service account that has got full access to Flink resources in an environment"
}

# ------------------------------------------------------
# ROLE BINDINGS
# ------------------------------------------------------
resource "confluent_role_binding" "statements-runner-environment-admin" {
  principal   = "User:${confluent_service_account.statements-runner.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.staging.resource_name
}

// https://docs.confluent.io/cloud/current/access-management/access-control/rbac/predefined-rbac-roles.html#flinkdeveloper
resource "confluent_role_binding" "app-manager-flink-developer" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = confluent_environment.staging.resource_name
}

resource "confluent_role_binding" "app-manager-flink-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkAdmin"
  crn_pattern = confluent_environment.staging.resource_name
}

// https://docs.confluent.io/cloud/current/access-management/access-control/rbac/predefined-rbac-roles.html#assigner
// https://docs.confluent.io/cloud/current/flink/operate-and-deploy/flink-rbac.html#submit-long-running-statements
resource "confluent_role_binding" "app-manager-assigner" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "Assigner"
  crn_pattern = "${data.confluent_organization.main.resource_name}/service-account=${confluent_service_account.statements-runner.id}"
}

resource "confluent_role_binding" "client-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.clients.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

resource "confluent_role_binding" "mongodb-sink-connector-cluster-admin" {
  principal   = "User:${confluent_service_account.mongodb-sink-connector.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

resource "confluent_role_binding" "client-schema-registry-developer-write" {
  principal   = "User:${confluent_service_account.clients.id}"
  crn_pattern = "${data.confluent_schema_registry_cluster.essentials.resource_name}/subject=*"
  role_name   = "DeveloperWrite"
}

# ------------------------------------------------------
# API KEYS
# ------------------------------------------------------
resource "confluent_api_key" "app-manager-flink-api-key" {
  display_name = "app-manager-flink-api-key"
  description  = "Flink API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }
  managed_resource {
    id          = data.confluent_flink_region.main.id
    api_version = data.confluent_flink_region.main.api_version
    kind        = data.confluent_flink_region.main.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
}

resource "confluent_api_key" "client-key" {
  display_name = "clients-api-key-${var.env_display_id_postfix}"
  description  = "client API Key"
  owner {
    id          = confluent_service_account.clients.id
    api_version = confluent_service_account.clients.api_version
    kind        = confluent_service_account.clients.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
}

resource "confluent_api_key" "clients-schema-registry-api-key" {
  display_name = "clients-sr-api-key-${var.env_display_id_postfix}"
  description  = "Schema Registry API Key"
  owner {
    id          = confluent_service_account.clients.id
    api_version = confluent_service_account.clients.api_version
    kind        = confluent_service_account.clients.kind
  }
  managed_resource {
    id          = data.confluent_schema_registry_cluster.essentials.id
    api_version = data.confluent_schema_registry_cluster.essentials.api_version
    kind        = data.confluent_schema_registry_cluster.essentials.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
}

resource "confluent_api_key" "mongodb-sink-connector-key" {
  display_name = "mongodb-sink-connector-api-key-${var.env_display_id_postfix}"
  description  = "MongoDB Connector API Key"
  owner {
    id          = confluent_service_account.mongodb-sink-connector.id
    api_version = confluent_service_account.mongodb-sink-connector.api_version
    kind        = confluent_service_account.mongodb-sink-connector.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
}

# ------------------------------------------------------
# Client Acls
# ------------------------------------------------------

resource "confluent_kafka_acl" "app-client-describe-on-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.clients.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.client-key.id
    secret = confluent_api_key.client-key.secret
  }
}

resource "confluent_kafka_acl" "app-client-read-on-target-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.clients.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.client-key.id
    secret = confluent_api_key.client-key.secret
  }
}

resource "confluent_kafka_acl" "app-client-write-to-data-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.clients.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.client-key.id
    secret = confluent_api_key.client-key.secret
  }
}

resource "confluent_kafka_acl" "mongodb-sink-connector-describe-on-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-read-on-target-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "products_summarized_with_embeddings" // TODO replace with var
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-create-on-dlq-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-write-on-dlq-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-create-on-success-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "success-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-write-on-success-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "success-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-create-on-error-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "error-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-write-on-error-lcc-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "error-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}

resource "confluent_kafka_acl" "mongodb-sink-connector-read-on-connect-lcc-group" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "GROUP"
  resource_name = "connect-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.mongodb-sink-connector.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.mongodb-sink-connector-key.id
    secret = confluent_api_key.mongodb-sink-connector-key.secret
  }
  depends_on = [
    confluent_role_binding.mongodb-sink-connector-cluster-admin
  ]
}


resource "confluent_connector" "mongo-db-sink" {
  environment {
    id = confluent_environment.staging.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-mongo-db-sink.html#configuration-properties
  config_sensitive = {
    "connection.password" = var.mongodb_password,
  }

  // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
  // https://docs.confluent.io/cloud/current/connectors/cc-mongo-db-sink.html#configuration-properties
  config_nonsensitive = {
    "connector.class"          = "MongoDbAtlasSink"
    "name"                     = "confluent-mongodb-sink"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.mongodb-sink-connector.id
    "connection.host"          = var.mongodb_host
    "connection.user"          = var.mongodb_user
    "input.data.format"        = "JSON_SR"
    "topics"                   = "products_summarized_with_embeddings" // TODO replace with var?
    "max.num.retries"          = "3"
    "retries.defer.timeout"    = "5000"
    "max.batch.size"           = "0"
    "database"                 = var.mongodbatlas_database
    "collection"               = var.mongodbatlas_collection
    "tasks.max"                = "1"
  }

  depends_on = [
    # also depends on the Flink scripts
    confluent_kafka_acl.mongodb-sink-connector-create-on-dlq-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-create-on-error-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-create-on-success-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-describe-on-cluster,
    confluent_kafka_acl.mongodb-sink-connector-write-on-dlq-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-write-on-error-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-write-on-success-lcc-topics,
    confluent_kafka_acl.mongodb-sink-connector-read-on-connect-lcc-group,
    confluent_kafka_acl.mongodb-sink-connector-read-on-target-topic,
    confluent_flink_statement.insert-data,
  ]
}