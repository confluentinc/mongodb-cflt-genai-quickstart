#!/usr/bin/env bash

set -eo pipefail

# Function to prompt for input until a non-empty value is provided
prompt_for_input() {
  local var_name=$1
  local prompt_message=$2
  local is_secret=$3

  while true; do
    if [ "$is_secret" = true ]; then
      read -r -s -p "$prompt_message: " input_value
      echo ""
    else
      read -r -p "$prompt_message: " input_value
    fi

    if [ -z "$input_value" ]; then
      echo "[-] $var_name cannot be empty"
    else
      eval "$var_name='$input_value'"
      break
    fi
  done
}

# Function to prompt for a yes/no response. returns 1 for yes, 0 for no
prompt_for_yes_no() {
  local prompt_message=$1
  local response

  while true; do
    read -r -p "$prompt_message [y/n]: " response
    case $response in
      [yY][eE][sS]|[yY])
        return 1
        ;;
      [nN][oO]|[nN])
        return 0
        ;;
      *)
        ;;
    esac
  done
}

# Set platform to linux/arm64 if m1 mac is detected. Otherwise set to linux/amd64
IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')

# Check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
  echo "[+] Initializing terraform"
  docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

# Prompt for AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  prompt_for_input AWS_ACCESS_KEY_ID "Enter your AWS_ACCESS_KEY_ID" false
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  prompt_for_input AWS_SECRET_ACCESS_KEY "Enter your AWS_SECRET_ACCESS_KEY" true
fi

# Prompt for AWS session token if needed
if ! prompt_for_yes_no "Do you have an AWS_SESSION_TOKEN?"; then
  prompt_for_input AWS_SESSION_TOKEN "Enter your AWS_SESSION_TOKEN" true
else
  # Unset AWS_SESSION_TOKEN if it was previously set
  unset AWS_SESSION_TOKEN
fi

# Default to us-east-1 if AWS_REGION is not set
if [ -z "$AWS_REGION" ]; then
  read -r -p "Enter the AWS region (default: us-east-1): " AWS_REGION
  AWS_REGION=${AWS_REGION:-us-east-1}
fi

# check for confluent cloud api key and secret
if [ -z "$CONFLUENT_CLOUD_API_KEY" ]; then
  prompt_for_input CONFLUENT_CLOUD_API_KEY "Enter your Confluent Cloud API Key" false
fi

if [ -z "$CONFLUENT_CLOUD_API_SECRET" ]; then
  prompt_for_input CONFLUENT_CLOUD_API_SECRET "Enter your Confluent Cloud API Secret" true
fi

if [ -z "$CONFLUENT_CLOUD_CREATE_ENVIRONMENT" ]; then
  if ! prompt_for_yes_no "Do you want to create a new Confluent Cloud environment?"; then
    CONFLUENT_CLOUD_CREATE_ENVIRONMENT=1
  else
    CONFLUENT_CLOUD_CREATE_ENVIRONMENT=0
  fi
fi

# check for confluent cloud api key and secret
if [ -z "$MONGODB_ORG_ID" ]; then
  prompt_for_input MONGODB_ORG_ID "Enter your MongoDB Org ID" false
fi

if [ -z "$MONGODB_PUBLIC_KEY" ]; then
  prompt_for_input MONGODB_PUBLIC_KEY "Enter your MongoDB Public Key" false
fi

if [ -z "$MONGODB_PRIVATE_KEY" ]; then
  prompt_for_input MONGODB_PRIVATE_KEY "Enter your MongoDB Private Key" true
fi

# Create .env file from variables set in this file
echo "[+] Setting up .env file for docker-compose"
cat << EOF > .env
IMAGE_ARCH=$IMAGE_ARCH
AWS_REGION=$AWS_REGION
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
CONFLUENT_CLOUD_API_KEY=$CONFLUENT_CLOUD_API_KEY
CONFLUENT_CLOUD_API_SECRET=$CONFLUENT_CLOUD_API_SECRET
MONGODB_PUBLIC_KEY=$MONGODB_PUBLIC_KEY
MONGODB_PRIVATE_KEY=$MONGODB_PRIVATE_KEY
MONGODB_ORG_ID=$MONGODB_ORG_ID
EOF

# Add AWS_SESSION_TOKEN to .env if it is set
if [ -n "$AWS_SESSION_TOKEN" ]; then
  echo "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> .env
fi

echo "[+] Setting up infrastructure/variables.tfvars"
# populate tfvars file with AWS credentials
cat << EOF > infrastructure/variables.tfvars
aws_region = "$AWS_REGION"
confluent_cloud_api_key = "$CONFLUENT_CLOUD_API_KEY"
confluent_cloud_api_secret = "$CONFLUENT_CLOUD_API_SECRET"
confluent_cloud_create_environment=$([ "$CONFLUENT_CLOUD_CREATE_ENVIRONMENT" -eq 1 ] && echo "true" || echo "false")
path_to_flink_sql_create_table_statements = "statements/create-tables"
path_to_flink_sql_create_model_statements = "statements/create-models"
path_to_flink_sql_insert_statements = "statements/insert"
mongodbatlas_public_key = "$MONGODB_PUBLIC_KEY"
mongodbatlas_private_key = "$MONGODB_PRIVATE_KEY"
mongodbatlas_org_id = "$MONGODB_ORG_ID"
EOF

echo "[+] Applying terraform"
docker compose run --remove-orphans --rm terraform apply --auto-approve -var-file=variables.tfvars
if [ $? -ne 0 ]; then
  echo "[-] Failed to apply terraform"
  exit 1
fi
echo "[+] Terraform apply complete"

echo "[+] Done"