#!/usr/bin/env bash
# this script is used to create a connection in the confluent cloud cluster by interacting with the rest api that the confluent cli uses.
# At the time of writing this script, the terraform provider does not support creating/managing flink connections in the confluent cloud cluster.
# It should be replaced or removed once its provided by the terraform provider.

set -oe pipefail

# Required environment variables
REQUIRED_ENV_VARS=(
  "FLINK_API_KEY" "FLINK_API_SECRET" "FLINK_ENV_ID" "FLINK_ORG_ID"
  "FLINK_REST_ENDPOINT" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_REGION"
)

# Check if required environment variables are set
for env_var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!env_var}" ]; then
    echo "Error: $env_var is not set"
    exit 1
  fi
done

# Encode API key and secret for basic authentication
BASIC_AUTH=$(echo -n "$FLINK_API_KEY:$FLINK_API_SECRET" | base64 -w 0)

# Prepare AWS authentication data
if [ -z "$AWS_SESSION_TOKEN" ]; then
  AUTH_DATA=$(jq -n -r --arg aws_access_key_id "$AWS_ACCESS_KEY_ID" --arg aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" \
  '{AWS_ACCESS_KEY_ID: $aws_access_key_id, AWS_SECRET_ACCESS_KEY: $aws_secret_access_key}' | jq '.|tostring')
else
  AUTH_DATA=$(jq -n -r --arg aws_access_key_id "$AWS_ACCESS_KEY_ID" --arg aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --arg aws_session_token "$AWS_SESSION_TOKEN" \
  '{AWS_ACCESS_KEY_ID: $aws_access_key_id, AWS_SECRET_ACCESS_KEY: $aws_secret_access_key, AWS_SESSION_TOKEN: $aws_session_token}' | jq '.|tostring')
fi

# Create connection in Confluent Cloud cluster
echo
curl --request POST \
  --url "$FLINK_REST_ENDPOINT/sql/v1/organizations/$FLINK_ORG_ID/environments/$FLINK_ENV_ID/connections" \
  --header "Authorization: Basic $BASIC_AUTH" \
  --header "content-type: application/json" \
  --data '{
    "name": "bedrock-titan-embed-connection",
    "spec": {
      "connection_type": "BEDROCK",
      "endpoint": "https://bedrock-runtime.'"$AWS_REGION"'.amazonaws.com/model/amazon.titan-embed-text-v2:0/invoke",
      "auth_data": {
        "kind": "PlaintextProvider",
        "data": '"$AUTH_DATA"'
      }
    }
  }' | jq . > titan-embed-connection-result.json

# Create connection in Confluent Cloud cluster
curl --request POST \
  --url "$FLINK_REST_ENDPOINT/sql/v1/organizations/$FLINK_ORG_ID/environments/$FLINK_ENV_ID/connections" \
  --header "Authorization: Basic $BASIC_AUTH" \
  --header "content-type: application/json" \
  --data '{
    "name": "bedrock-claude-3-haiku-connection",
    "spec": {
      "connection_type": "BEDROCK",
      "endpoint": "https://bedrock-runtime.'"$AWS_REGION"'.amazonaws.com/model/anthropic.claude-3-haiku-20240307-v1:0/invoke",
      "auth_data": {
        "kind": "PlaintextProvider",
        "data": '"$AUTH_DATA"'
      }
    }
  }' | jq . > claude-3-haiku-connection-result.json