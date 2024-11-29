#!/usr/bin/env bash

set -eo pipefail

# Function to display help message
show_help() {
    echo "Usage: $0 [options] [env_file]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Arguments:"
    echo "  env_file      Optional path to an environment file to load"
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

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

if ! docker info > /dev/null 2>&1; then
  echo 'Error: Docker is not running.' >&2
  exit 1
fi


# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
    touch .env
    echo "[+] Initializing terraform"
    IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

# Support for already existing .env file
DEFAULT_ENV_FILE=$1
# Check if an environment file is provided and source it
if [[ -n "$DEFAULT_ENV_FILE" && "$DEFAULT_ENV_FILE" != "-h" && "$DEFAULT_ENV_FILE" != "--help" ]]; then
    if [[ -f "$DEFAULT_ENV_FILE" ]]; then
        echo "[+] Sourcing environment file '$DEFAULT_ENV_FILE'"
        source "$DEFAULT_ENV_FILE"
    else
        echo "Error: Environment file '$DEFAULT_ENV_FILE' not found."
        exit 1
    fi
fi

# Prompt for AWS credentials
[ -z "$AWS_ACCESS_KEY_ID" ] && prompt_for_input AWS_ACCESS_KEY_ID "Enter your AWS_ACCESS_KEY_ID" false
[ -z "$AWS_SECRET_ACCESS_KEY" ] && prompt_for_input AWS_SECRET_ACCESS_KEY "Enter your AWS_SECRET_ACCESS_KEY" true

# Prompt for AWS session token if needed
if ! prompt_for_yes_no "Do you have an AWS_SESSION_TOKEN?"; then
    [ -z "$AWS_SESSION_TOKEN" ] && prompt_for_input AWS_SESSION_TOKEN "Enter your AWS_SESSION_TOKEN" true
else
    unset AWS_SESSION_TOKEN
fi

# Default to us-east-1 if AWS_REGION is not set
[ -z "$AWS_REGION" ] && read -r -p "Enter the AWS region (default: us-east-1): " AWS_REGION && AWS_REGION=${AWS_REGION:-us-east-1}

# Prompt for Confluent Cloud and MongoDB credentials
[ -z "$CONFLUENT_CLOUD_API_KEY" ] && prompt_for_input CONFLUENT_CLOUD_API_KEY "Enter your Confluent Cloud API Key" false
[ -z "$CONFLUENT_CLOUD_API_SECRET" ] && prompt_for_input CONFLUENT_CLOUD_API_SECRET "Enter your Confluent Cloud API Secret" true
[ -z "$MONGODB_ORG_ID" ] && prompt_for_input MONGODB_ORG_ID "Enter your MongoDB Org ID" false
[ -z "$MONGODB_PUBLIC_KEY" ] && prompt_for_input MONGODB_PUBLIC_KEY "Enter your MongoDB Public Key" false
[ -z "$MONGODB_PRIVATE_KEY" ] && prompt_for_input MONGODB_PRIVATE_KEY "Enter your MongoDB Private Key" true

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
[ -n "$AWS_SESSION_TOKEN" ] && echo "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> .env

echo "[+] Setting up infrastructure/variables.tfvars"
# populate tfvars file with AWS credentials
cat << EOF > infrastructure/variables.tfvars
aws_region = "$AWS_REGION"
confluent_cloud_region = "$AWS_REGION"
mongodbatlas_cloud_region = "$AWS_REGION"
confluent_cloud_api_key = "$CONFLUENT_CLOUD_API_KEY"
confluent_cloud_api_secret = "$CONFLUENT_CLOUD_API_SECRET"
path_to_flink_sql_create_table_statements = "statements/create-tables"
path_to_flink_sql_create_model_statements = "statements/create-models"
path_to_flink_sql_insert_statements = "statements/insert"
mongodbatlas_public_key = "$MONGODB_PUBLIC_KEY"
mongodbatlas_private_key = "$MONGODB_PRIVATE_KEY"
mongodbatlas_org_id = "$MONGODB_ORG_ID"
EOF

echo "[+] Applying terraform"
IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform apply --auto-approve -var-file=variables.tfvars
if [ $? -ne 0 ]; then
    echo "[-] Failed to apply terraform"
    exit 1
fi

echo "[+] Terraform apply complete"
echo "[+] Done"