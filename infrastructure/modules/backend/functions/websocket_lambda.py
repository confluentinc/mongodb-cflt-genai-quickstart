import json
import logging
import os

from botocore.exceptions import ClientError
from confluent_kafka import Producer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONSerializer
from confluent_kafka.serialization import SerializationContext, MessageField

from chat_input import ChatInputValue, ChatInputKey

logger = logging.getLogger()
logger.setLevel(logging.INFO)
topics = {"input": "chat_input", "connect": "chat_connect", "disconnect": "chat_disconnect"}


def handle_connect(producer: Producer, connection_id):
    try:
        logger.info("Sending connection %s event to Kafka", connection_id)
        producer.produce(topic=topics["connect"], value=f"Connection {connection_id} established")
        producer.flush()
        logger.info("Added connection %s.", connection_id)
        return 200
    except ClientError:
        logger.exception("Couldn't add connection %s.", connection_id)
        return 503


def handle_disconnect(producer: Producer, connection_id):
    try:
        producer.produce(topic=topics["disconnect"], value=f"Connection {connection_id} disconnected")
        producer.flush()
        logger.info("Disconnected connection %s.", connection_id)
        return 200
    except ClientError:
        logger.exception("Couldn't disconnect connection %s.", connection_id)
        return 503


def handle_message(producer: Producer, key_json_serializer: JSONSerializer, value_json_serializer: JSONSerializer,
                   json_body, connection_id, message_id, request_time):
    try:
        json_body["sessionId"] = connection_id
        json_body["createdAt"] = request_time
        json_body["messageId"] = message_id
        chat_input_key = ChatInputKey.from_dict(json_body)
        chat_input_value = ChatInputValue.from_dict(json_body)
        logger.info("Sending message key: %s, value: %s to Kafka", chat_input_key, chat_input_value)
        producer.produce(
            topic=topics["input"],
            key=key_json_serializer(chat_input_key, SerializationContext(topics["input"], MessageField.KEY)),
            value=value_json_serializer(chat_input_value, SerializationContext(topics["input"], MessageField.VALUE)),
        )
        producer.flush()
        logger.info("Sent message %s.", chat_input_value.message_id)
        return 200
    except ValueError:
        logger.exception("Unable to create python object from json. Missing required one of ['userId', 'input']")
        return 400
    except TypeError:
        logger.exception("Couldn't parse JSON body.")
        return 400
    except AttributeError:
        logger.exception("Couldn't parse JSON body.")
        return 400
    except ClientError:
        logger.exception("Couldn't get user name.")
        return 503


def lambda_handler(event, context):
    required_env_vars = [
        'SCHEMA_REGISTRY_URL', 'SCHEMA_REGISTRY_KEY_ID', 'SCHEMA_REGISTRY_KEY_SECRET',
        'BOOTSTRAP_SERVERS', 'KAFKA_KEY_ID', 'KAFKA_KEY_SECRET'
    ]
    route_key = event.get("requestContext", {}).get("routeKey")
    connection_id = event.get("requestContext", {}).get("connectionId")
    message_id = event.get("requestContext", {}).get("messageId")
    request_time = event.get("requestContext", {}).get("requestTimeEpoch")
    missing_vars = [var for var in required_env_vars if os.environ.get(var) is None]

    if missing_vars or route_key is None or connection_id is None:
        logger.error("Missing required environment variables: %s", missing_vars)
        logger.error("Route key: %s", route_key)
        logger.error("Connection ID: %s", connection_id)
        return {"statusCode": 400}

    sr_config = {
        'url': os.environ['SCHEMA_REGISTRY_URL'],
        'basic.auth.user.info': f"{os.environ['SCHEMA_REGISTRY_KEY_ID']}:{os.environ['SCHEMA_REGISTRY_KEY_SECRET']}",
    }
    producer_conf = {
        'bootstrap.servers': os.environ['BOOTSTRAP_SERVERS'],
        'sasl.username': os.environ['KAFKA_KEY_ID'],
        'sasl.password': os.environ['KAFKA_KEY_SECRET'],
        'security.protocol': 'SASL_SSL',
        'sasl.mechanisms': 'PLAIN',
        'acks': 'all',
        'client.id': 'PIE_LABS|GENAI_MONGODB_QUICKSTART',
    }

    schema_registry_client = SchemaRegistryClient(sr_config)
    value_json_serializer = JSONSerializer(ChatInputValue.json_schema(), schema_registry_client,
                                           ChatInputValue.to_dict)
    key_json_serializer = JSONSerializer(ChatInputKey.json_schema(), schema_registry_client, ChatInputKey.to_dict)
    producer = Producer(producer_conf)

    logger.info("Request: %s", route_key)
    logger.info("Connection ID: %s", connection_id)
    logger.info("Event: %s", event)

    if route_key == "$connect":
        return {"statusCode": handle_connect(producer, connection_id)}
    elif route_key == "$disconnect":
        return {"statusCode": handle_disconnect(producer, connection_id)}
    else:
        domain = event.get("requestContext", {}).get("domainName")
        stage = event.get("requestContext", {}).get("stage")
        if domain is None or stage is None:
            logger.warning("Couldn't send message. Bad endpoint in request: domain '%s', stage '%s'", domain, stage)
            return {"statusCode": 400}
        try:
            json_body = json.loads(event.get("body"))
            if json_body is None:
                logger.warning("No JSON body in request.")
                return {"statusCode": 400}
            return {
                "statusCode": handle_message(producer, key_json_serializer, value_json_serializer, json_body,
                                             connection_id, message_id, request_time)}
        except json.JSONDecodeError:
            logger.warning("Couldn't parse JSON body.")
            return {"statusCode": 400}
