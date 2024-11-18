import base64
import json
import logging
import os

import boto3
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONDeserializer
from confluent_kafka.serialization import SerializationContext, MessageField

from chat_output import ChatOutputValue, ChatOutputKey

logger = logging.getLogger()
logger.setLevel(logging.INFO)
source_topic = "chat_output"


def lambda_handler(event, context):
    required_env_vars = [
        'SCHEMA_REGISTRY_URL', 'SCHEMA_REGISTRY_KEY_ID', 'SCHEMA_REGISTRY_KEY_SECRET', 'APIGATEWAY_CONNECTIONS_ENDPOINT'
    ]
    logger.info("Event: %s", event)
    logger.info("Context: %s", context)

    missing_vars = [var for var in required_env_vars if os.environ.get(var) is None]

    if missing_vars:
        logger.error("Missing required environment variables: %s", missing_vars)
        return {"statusCode": 400}

    sr_config = {
        'url': os.environ['SCHEMA_REGISTRY_URL'],
        'basic.auth.user.info': f"{os.environ['SCHEMA_REGISTRY_KEY_ID']}:{os.environ['SCHEMA_REGISTRY_KEY_SECRET']}",
    }

    schema_registry_client = SchemaRegistryClient(sr_config)
    value_json_deserializer = JSONDeserializer(ChatOutputValue.json_schema(), ChatOutputValue.from_dict,
                                               schema_registry_client)
    key_json_deserializer = JSONDeserializer(ChatOutputKey.json_schema(), ChatOutputKey.from_dict,
                                             schema_registry_client)
    apig_management_client = boto3.client("apigatewaymanagementapi",
                                          endpoint_url=os.environ['APIGATEWAY_CONNECTIONS_ENDPOINT'])
    try:
        for topic_partition, messages in event['records'].items():
            for message in messages:
                key: ChatOutputKey = key_json_deserializer(base64.b64decode(message['key']),
                                                           SerializationContext(source_topic, MessageField.KEY))
                value: ChatOutputValue = value_json_deserializer(base64.b64decode(message['value']),
                                                                 SerializationContext(source_topic, MessageField.VALUE))
                logger.info("Key: %s", key)
                logger.info("Value: %s", value)
                connection_id = key.session_id
                logger.info("Connection ID: %s", connection_id)
                response = apig_management_client.post_to_connection(
                    ConnectionId=connection_id,
                    Data=json.dumps(ChatOutputValue.to_dict(value))
                )
                logger.info("Response: %s", response)
        return {"statusCode": 200}
    except Exception as e:
        logger.exception("Error processing records.")
        return {"statusCode": 500}
