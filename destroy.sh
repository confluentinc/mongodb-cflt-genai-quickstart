#!/usr/bin/env bash

set -eo pipefail

# Check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

# destroy infrastructure
# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
  echo "[+] Terraform is not initialized"
  docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

echo "[+] Destroying infrastructure"
docker compose run --rm terraform destroy -auto-approve -var-file=variables.tfvars || { echo "[-] Failed to destroy infrastructure"; exit 1; }

echo "[+] Infrastructure destroyed successfully"
# delete .env and infrastructure/variables.tf
echo "[+] Cleaning up .env and infrastructure/variables.tf"
rm -f .env
rm -f infrastructure/variables.tfvars
echo "[+] Clean up completed"