data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "aws_websocket_api" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  # API
  description = "Chatbot AWS API Websocket Gateway"
  name        = "chatbot-api-${var.env_display_id_postfix}"

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
    log_group_retention_in_days = 1
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
  layer_name               = "GenAiQuickstartWebsocketChatApiLayer-${var.env_display_id_postfix}"
  compatible_runtimes      = ["python3.12"]
  runtime                  = "python3.12"
  compatible_architectures = [var.system_architecture]
  source_path = [
    {
      pip_requirements = "${path.module}/functions/requirements.txt",
      prefix_in_zip    = "python",
    }
  ]
}

module "websocket_chat_api_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiQuickstartWebsocketChatApi-${var.env_display_id_postfix}"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Quickstart Websocket Chat Api"
  handler       = "websocket_lambda.lambda_handler"
  runtime       = "python3.12"
  architectures = [var.system_architecture]

  environment_variables = {
    SCHEMA_REGISTRY_URL        = var.schema_registry_url
    SCHEMA_REGISTRY_KEY_ID     = var.schema_registry_api_key.id
    SCHEMA_REGISTRY_KEY_SECRET = var.schema_registry_api_key.secret
    BOOTSTRAP_SERVERS          = var.bootstrap_servers
    KAFKA_KEY_ID               = var.kafka_api_key.id
    KAFKA_KEY_SECRET           = var.kafka_api_key.secret
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

# Required for the Lambda function to connect to the Kafka cluster
resource "aws_secretsmanager_secret" "confluent_cloud_genai_quickstart" {
  name                    = "confluent/chatbot-api/creds/${var.env_display_id_postfix}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "confluent_cloud_schema_registry" {
  name                    = "confluent/vectorsearch/schema-registry/creds/${var.env_display_id_postfix}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "mongodb" {
  name                    = "confluent/vectorsearch/mongo/creds/${var.env_display_id_postfix}"
  recovery_window_in_days = 0
}


resource "aws_secretsmanager_secret_version" "confluent_cloud_genai_quickstart_version" {
  secret_id = aws_secretsmanager_secret.confluent_cloud_genai_quickstart.id
  secret_string = jsonencode({
    "username" : var.kafka_api_key.id,
    "password" : var.kafka_api_key.secret
  })
}

resource "aws_secretsmanager_secret_version" "confluent_cloud_schema_registry_version" {
  secret_id = aws_secretsmanager_secret.confluent_cloud_schema_registry.id
  secret_string = jsonencode({
    "username" : var.schema_registry_api_key.id,
    "password" : var.schema_registry_api_key.secret
  })
}

resource "aws_secretsmanager_secret_version" "mongodb_version" {
  secret_id = aws_secretsmanager_secret.mongodb.id
  secret_string = jsonencode({
    "username" : var.mongodb_db_user.id,
    "password" : var.mongodb_db_user.secret
  })
}

module "lambda_trigger_connections_api" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiQuickstartKafkaTriggerWebsocketConnectionsApi-${var.env_display_id_postfix}"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Quickstart Kafka Trigger Websocket Connections Api"
  handler       = "kafkatrigger_lambda.lambda_handler"
  runtime       = "python3.12"
  architectures = [var.system_architecture]
  timeout       = 300

  environment_variables = {
    SCHEMA_REGISTRY_URL             = var.schema_registry_url
    SCHEMA_REGISTRY_KEY_ID          = var.schema_registry_api_key.id
    SCHEMA_REGISTRY_KEY_SECRET      = var.schema_registry_api_key.secret
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
      topics            = [var.connections_api_topics_info.input_topic]
      self_managed_event_source = [
        {
          endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.bootstrap_servers
          }
        }
      ]
      self_managed_kafka_event_source_config = [
        {
          consumer_group_id = "genai-quickstart-lambda-trigger-connections-api-${var.env_display_id_postfix}"
        }
      ]
      source_access_configuration = [
        {
          type = "BASIC_AUTH",
          uri  = aws_secretsmanager_secret.confluent_cloud_genai_quickstart.arn
        },
      ]
    }
  }
  attach_policy_statements = true
  policy_statements = {
    secrets_manager_get_value = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"],
      resources = [aws_secretsmanager_secret.confluent_cloud_genai_quickstart.arn]
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

module "lambda_trigger_vector_search" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiQuickstartKafkaTriggerVectorSearch-${var.env_display_id_postfix}"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description                       = "GenAi Quickstart Kafka Trigger Vector Search"
  handler                           = "io.confluent.pie.search.SearchHandler::handleRequest"
  runtime                           = "java17"
  architectures                     = [var.system_architecture]
  timeout                           = 600
  snap_start                        = false
  provisioned_concurrent_executions = 1

  environment_variables = {
    SR_URL    = var.schema_registry_url
    SR_SECRET = aws_secretsmanager_secret.confluent_cloud_schema_registry.name
    # Change this to be the path to the aws secret manager secret
    KAFKA_SECRET_KEY      = aws_secretsmanager_secret.confluent_cloud_genai_quickstart.name
    BROKER                = var.bootstrap_servers
    MONGO_CREDENTIALS     = aws_secretsmanager_secret.mongodb.name
    MONGO_HOST            = var.mongodb_db_info.host
    MONGO_DB_NAME         = var.mongodb_db_info.db_name
    MONGO_COLLECTION_NAME = var.mongodb_vectorsearch_info.collection_name
    MONGO_INDEX_NAME      = var.mongodb_vectorsearch_info.index_name
    MONGO_FIELD_PATH      = var.mongodb_vectorsearch_info.field_path
    SEARCH_RESULT_TOPIC   = var.vectorsearch_topics_info.output_topic
    JAVA_TOOL_OPTIONS     = "-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  }

  layers = [
    local.selected_extension_arn
  ]

  source_path = [
    {
      path = "${path.module}/search/",
      commands = [
        "mvn clean package",
        "cd target/output",
        ":zip"
      ]
    }
  ]

  publish = true

  event_source_mapping = {
    self_managed_kafka = {
      batch_size        = 1
      starting_position = "LATEST"
      topics            = [var.vectorsearch_topics_info.input_topic]
      self_managed_event_source = [
        {
          endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.bootstrap_servers
          }
        }
      ]
      self_managed_kafka_event_source_config = [
        {
          consumer_group_id = "genai-quickstart-lambda-vector-search-${var.env_display_id_postfix}"
        }
      ]
      source_access_configuration = [
        {
          type = "BASIC_AUTH",
          uri  = aws_secretsmanager_secret.confluent_cloud_genai_quickstart.arn
        },
      ]
    }
  }
  attach_policy_statements = true
  policy_statements = {
    secrets_manager_get_value = {
      effect  = "Allow",
      actions = ["secretsmanager:GetSecretValue"],
      resources = [
        aws_secretsmanager_secret.confluent_cloud_genai_quickstart.arn,
        aws_secretsmanager_secret.confluent_cloud_schema_registry.arn, aws_secretsmanager_secret.mongodb.arn
      ]
    }
  }

}