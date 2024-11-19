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
  layer_name               = "GenAiDemoWebsocketChatApiLayer-${var.env_display_id_postfix}"
  compatible_runtimes      = ["python3.12"]
  runtime                  = "python3.12"
  compatible_architectures = [var.system_architecture]
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

  function_name = "GenAiDemoWebsocketChatApi-${var.env_display_id_postfix}"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Demo Websocket Chat Api"
  handler       = "websocket_lambda.lambda_handler"
  runtime       = "python3.12"
  architectures = [var.system_architecture]
  timeout       = 300

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

################################################################################
# Lambda Trigger Connections Api
################################################################################

# Required for the Lambda function to connect to the Kafka cluster
resource "aws_secretsmanager_secret" "confluent_cloud_genai_demo" {
  name = "confluent/chatbot-api/creds/${var.env_display_id_postfix}"
}


resource "aws_secretsmanager_secret_version" "confluent_cloud_genai_demo_version" {
  secret_id = aws_secretsmanager_secret.confluent_cloud_genai_demo.id
  # format of the string is {"username":"my-username","password":"my-password"}
  secret_string = jsonencode({
    "username" : var.kafka_api_key.id,
    "password" : var.kafka_api_key.secret
  })
}

module "lambda_trigger_connections_api" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "GenAiDemoKafkaTriggerWebsocketConnectionsApi-${var.env_display_id_postfix}"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 1

  description   = "GenAi Demo Kafka Trigger Websocket Connections Api"
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
      topics            = ["chat_output"]
      self_managed_event_source = [
        {
          endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.bootstrap_servers
          }
        }
      ]
      self_managed_kafka_event_source_config = [
        {
          consumer_group_id = "genai-demo-lambda-trigger-connections-api-${var.env_display_id_postfix}"
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