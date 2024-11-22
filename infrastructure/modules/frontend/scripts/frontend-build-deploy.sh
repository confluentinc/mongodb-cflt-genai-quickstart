#!/bin/bash
set -e

# insufficient arguments or help
if [ $# -ne 2 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: $0 <WS_URL> <BUCKET_NAME>"
  exit 1
fi

WS_URL=$1
BUCKET_NAME=$2

source ~/.bashrc
cd ../frontend
echo "WS_URL=$WS_URL" > .env
(npm i && npm run clean && npm run build) >&2
aws s3 cp dist/ s3://"$2"/ --recursive