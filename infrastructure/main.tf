resource "random_id" "env_display_id" {
  byte_length = 4
}

data "confluent_organization" "main" {}

# ------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------

resource "confluent_environment" "staging" {
  display_name = "genai-demo-${random_id.env_display_id.hex}"

  stream_governance {
    package = "ESSENTIALS"
  }
}

data "confluent_environment" "staging" {
  id = confluent_environment.staging.id
}

# ------------------------------------------------------
# KAFKA
# ------------------------------------------------------

// In Confluent Cloud, an environment is mapped to a Flink catalog, and a Kafka cluster is mapped to a Flink database.
resource "confluent_kafka_cluster" "standard" {
  display_name = "genai-demo"
  availability = "SINGLE_ZONE"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  standard {}
  environment {
    id = data.confluent_environment.staging.id
  }
}

# ------------------------------------------------------
# Schema Registry
# ------------------------------------------------------
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = data.confluent_environment.staging.id
  }

  depends_on = [
    confluent_kafka_cluster.standard
  ]
}

# ------------------------------------------------------
# FLINK
# ------------------------------------------------------
data "confluent_flink_region" "main" {
  cloud  = var.confluent_cloud_service_provider
  region = var.confluent_cloud_region
}

# https://docs.confluent.io/cloud/current/flink/get-started/quick-start-cloud-console.html#step-1-create-a-af-compute-pool
resource "confluent_flink_compute_pool" "main" {
  display_name = "genai-demo-flink-compute-pool"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  max_cfu      = 30
  environment {
    id = data.confluent_environment.staging.id
  }
  depends_on = [
    confluent_role_binding.statements-runner-environment-admin,
    confluent_role_binding.app-manager-assigner,
    confluent_role_binding.app-manager-flink-developer,
    confluent_api_key.app-manager-flink-api-key,
  ]
}

resource "confluent_flink_statement" "create-tables" {
  for_each = local.create_table_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = data.confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = data.confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath("${each.value}"))
}

resource "confluent_flink_statement" "create-models" {
  for_each = local.create_model_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = data.confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = data.confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath("${each.value}"))
}

resource "confluent_flink_statement" "insert-data" {
  for_each = local.insert_data_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = data.confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = data.confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath("${each.value}"))

  depends_on = [
    confluent_flink_statement.create-tables
  ]
}

# ------------------------------------------------------
# SERVICE ACCOUNTS
# ------------------------------------------------------

// Service account for kafka clients that will be used to produce and consume messages
resource "confluent_service_account" "clients" {
  display_name = "client-sa"
  description  = "Service account for clients"
}

// Service account to perform a task within Confluent Cloud, such as executing a Flink statement
resource "confluent_service_account" "statements-runner" {
  display_name = "statements-runner"
  description  = "Service account for running Flink Statements in the Kafka cluster"
}

// Service account that owns Flink API Key
resource "confluent_service_account" "app-manager" {
  display_name = "app-manager"
  description  = "Service account that has got full access to Flink resources in an environment"
}

# ------------------------------------------------------
# ROLE BINDINGS
# ------------------------------------------------------
resource "confluent_role_binding" "statements-runner-environment-admin" {
  principal   = "User:${confluent_service_account.statements-runner.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = data.confluent_environment.staging.resource_name
}

// https://docs.confluent.io/cloud/current/access-management/access-control/rbac/predefined-rbac-roles.html#flinkdeveloper
resource "confluent_role_binding" "app-manager-flink-developer" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = data.confluent_environment.staging.resource_name
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
      id = data.confluent_environment.staging.id
    }
  }
}

resource "confluent_api_key" "client_key" {
  display_name = "clients-api-key-${random_id.env_display_id.hex}"
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
  display_name = "clients-sr-api-key-${random_id.env_display_id.hex}"
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
    key    = confluent_api_key.client_key.id
    secret = confluent_api_key.client_key.secret
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
    key    = confluent_api_key.client_key.id
    secret = confluent_api_key.client_key.secret
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
    key    = confluent_api_key.client_key.id
    secret = confluent_api_key.client_key.secret
  }
}

################################################################################
# API Gateway Websocket API
################################################################################

module "aws_websocket_api" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  # API
  description = "Chatbot AWS API Websocket Gateway"
  name        = "chatbot-api"



  # Custom Domain
  create_domain_name    = false
  create_domain_records = false

  # Websocket
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  # Routes & Integration(s)
  routes = {
    "$connect" = {
      operation_name = "ConnectRoute"

      integration = {
        uri = module.websocket_chat_api_lambda.lambda_function_invoke_arn
      }
    },
    "$disconnect" = {
      operation_name = "DisconnectRoute"

      integration = {
        uri = module.websocket_chat_api_lambda.lambda_function_invoke_arn
      }
    },
    "$default" = {
      operation_name = "DefaultRoute"

      integration = {
        uri = module.websocket_chat_api_lambda.lambda_function_invoke_arn
      }
    },
  }

  # Stage
  deploy_stage = true
  stage_name   = "prod"

  stage_default_route_settings = {
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

}


module "websocket_chat_api_lambda_layer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  create_function          = false
  create_layer             = true
  layer_name               = "GenAiDemoWebsocketChatApiLayer"
  compatible_runtimes      = ["python3.12"]
  runtime                  = "python3.12"
  compatible_architectures = [local.system_architecture]
  build_in_docker          = true
  # this is required due to https://www.linkedin.com/pulse/how-create-confluent-python-lambda-layer-braeden-quirante/
  source_path = [
    {
      pip_requirements = "${path.module}/functions/requirements.txt",
      prefix_in_zip    = "python"
    }
  ]
}

module "websocket_chat_api_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiDemoWebsocketChatApi"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Demo Websocket Chat Api"
  handler       = "websocket_lambda.lambda_handler"
  runtime       = "python3.12"
  architectures = [local.system_architecture]
  timeout       = 300

  environment_variables = {
    SCHEMA_REGISTRY_URL        = data.confluent_schema_registry_cluster.essentials.rest_endpoint
    SCHEMA_REGISTRY_KEY_ID     = confluent_api_key.clients-schema-registry-api-key.id
    SCHEMA_REGISTRY_KEY_SECRET = confluent_api_key.clients-schema-registry-api-key.secret
    BOOTSTRAP_SERVERS          = replace(confluent_kafka_cluster.standard.bootstrap_endpoint, "SASL_SSL://", "")
    KAFKA_KEY_ID               = confluent_api_key.client_key.id
    KAFKA_KEY_SECRET           = confluent_api_key.client_key.secret
  }

  layers = [
    module.websocket_chat_api_lambda_layer.lambda_layer_arn
  ]

  source_path = [
    "${path.module}/functions/websocket_lambda.py",
    "${path.module}/functions/chat_input.py"
  ]

  publish = true

  allowed_triggers = {
    apigateway = {
      service    = "apigateway"
      source_arn = "${module.aws_websocket_api.api_execution_arn}/*/*"
    }
  }

  depends_on = [
    module.websocket_chat_api_lambda_layer
  ]
}

################################################################################
# Lambda Trigger Connections Api
################################################################################

# Required for the Lambda function to connect to the Kafka cluster
resource "aws_secretsmanager_secret" "confluent_cloud_genai_demo" {
  name = "confluent/chatbot-api/creds"
}


resource "aws_secretsmanager_secret_version" "confluent_cloud_genai_demo_version" {
  secret_id = aws_secretsmanager_secret.confluent_cloud_genai_demo.id
  # format of the string is {"username":"my-username","password":"my-password"}
  secret_string = jsonencode({
    "username" : confluent_api_key.client_key.id,
    "password" : confluent_api_key.client_key.secret
  })
}

module "lambda_trigger_connections_api" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiDemoKafkaTriggerWebsocketConnectionsApi"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Demo Kafka Trigger Websocket Connections Api"
  handler       = "kafkatrigger_lambda.lambda_handler"
  runtime       = "python3.12"
  architectures = [local.system_architecture]
  timeout       = 300

  environment_variables = {
    SCHEMA_REGISTRY_URL             = data.confluent_schema_registry_cluster.essentials.rest_endpoint
    SCHEMA_REGISTRY_KEY_ID          = confluent_api_key.clients-schema-registry-api-key.id
    SCHEMA_REGISTRY_KEY_SECRET      = confluent_api_key.clients-schema-registry-api-key.secret
    APIGATEWAY_CONNECTIONS_ENDPOINT = replace("${module.aws_websocket_api.api_endpoint}/${module.aws_websocket_api.stage_id}", "wss://", "https://")
  }

  layers = [
    module.websocket_chat_api_lambda_layer.lambda_layer_arn
  ]

  source_path = [
    "${path.module}/functions/kafkatrigger_lambda.py",
    "${path.module}/functions/chat_output.py"
  ]

  publish = true

  event_source_mapping = {
    self_managed_kafka = {
      batch_size        = 1
      starting_position = "LATEST"
      topics            = ["chat_output"]
      self_managed_event_source = [
        {
          endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = replace(confluent_kafka_cluster.standard.bootstrap_endpoint, "SASL_SSL://", "")
          }
        }
      ]
      self_managed_kafka_event_source_config = [
        {
          consumer_group_id = "genai-demo-lambda-trigger-connections-api"
        }
      ]
      source_access_configuration = [
        {
          type = "BASIC_AUTH",
          uri  = aws_secretsmanager_secret.confluent_cloud_genai_demo.arn
        },
      ]
    }
  }
  attach_policy_statements = true
  policy_statements = {
    secrets_manager_get_value = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.confluent_cloud_genai_demo.arn]
    },
    manage_connections = {
      effect    = "Allow",
      actions   = ["execute-api:*"],
      resources = ["${module.aws_websocket_api.api_execution_arn}/*/*/*"]
    }
  }

  depends_on = [
    module.websocket_chat_api_lambda_layer
  ]
}

################################################################################
# Deploying the Frontend
################################################################################

resource "aws_s3_bucket" "frontend" {
  bucket        = "genai-demo-frontend-${random_id.env_display_id.hex}"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend" {
  depends_on = [
    aws_s3_bucket_ownership_controls.frontend,
    aws_s3_bucket_public_access_block.frontend,
  ]

  bucket = aws_s3_bucket.frontend.id
  acl    = "private"
}

# Build the frontend
resource "null_resource" "frontend_build_and_deploy" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/frontend-build-deploy.sh ${module.aws_websocket_api.api_endpoint}/${module.aws_websocket_api.stage_id} ${aws_s3_bucket.frontend.bucket}"
  }

  depends_on = [module.aws_websocket_api.api_endpoint, module.aws_websocket_api.stage_id]
  triggers = {
    always_run = timestamp()
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

## Create Origin Access Control as this is required to allow access to the s3 bucket without public access to the S3 bucket.
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "genai-demo-frontend-${random_id.env_display_id.hex}"
  description                       = "Origin Access Control for the genai-demo-frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## Create CloudFront distribution group
resource "aws_cloudfront_distribution" "frontend" {
  depends_on = [
    aws_s3_bucket.frontend,
    aws_cloudfront_origin_access_control.frontend
  ]

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.frontend.id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.frontend.id
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

## Create policy to allow CloudFront to reach S3 bucket
data "aws_iam_policy_document" "frontend" {
  depends_on = [
    aws_cloudfront_distribution.frontend,
    aws_s3_bucket.frontend
  ]
  statement {
    sid    = "3"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}

## Assign policy to allow CloudFront to reach S3 bucket
resource "aws_s3_bucket_policy" "frontend" {
  depends_on = [
    aws_cloudfront_distribution.frontend
  ]
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend.json
}