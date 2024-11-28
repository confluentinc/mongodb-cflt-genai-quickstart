#!/usr/bin/env bash

set -eo pipefail

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

# destroy infrastructure
# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
  echo "[+] Terraform is not initialized"
  IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

echo "[+] Destroying infrastructure"
IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform destroy -auto-approve -var-file=variables.tfvars || { echo "[-] Failed to destroy infrastructure"; exit 1; }

echo "[+] Infrastructure destroyed successfully"
# delete .env and infrastructure/variables.tf
echo "[+] Cleaning up .env and infrastructure/variables.tf"
rm -f .env
rm -f infrastructure/variables.tfvars
echo "[+] Clean up completed"