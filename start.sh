#!/usr/bin/env bash
# Start the Docker Compose environment and deploy DynamoDB CDC Source Connector
set -euo pipefail

COMPOSE_FILE="docker-compose.yml"
CONNECT_URL="http://localhost:8083"
DYNAMODB_ENDPOINT="http://localhost:8000"

# Use dummy AWS credentials for local DynamoDB
export AWS_ACCESS_KEY_ID=dummy
export AWS_SECRET_ACCESS_KEY=dummy
export AWS_DEFAULT_REGION=us-west-2

# Start all services in the background
printf '\nStarting Docker Compose services...\n'
docker compose -f "$COMPOSE_FILE" up -d

# Wait for Kafka Connect REST API to be available
printf 'Waiting for Kafka Connect to be ready'
until curl -sf "$CONNECT_URL/connectors" >/dev/null 2>&1; do
  printf '.'
  sleep 5
done
printf '\nKafka Connect is up!\n'

# Create a DynamoDB table with streams enabled if it does not exist
if ! aws dynamodb describe-table --table-name TestTable --endpoint-url "$DYNAMODB_ENDPOINT" >/dev/null 2>&1; then
  printf '\nCreating DynamoDB table...\n'
  aws dynamodb create-table \
    --table-name TestTable \
    --attribute-definitions AttributeName=Id,AttributeType=S \
    --key-schema AttributeName=Id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES \
    --endpoint-url "$DYNAMODB_ENDPOINT" >/dev/null

  # Insert sample item to capture in snapshot
  aws dynamodb put-item \
    --table-name TestTable \
    --item '{"Id": {"S": "1"}, "Info": {"S": "initial"}}' \
    --endpoint-url "$DYNAMODB_ENDPOINT" >/dev/null
fi

printf 'Deploying DynamoDB CDC Source connector...\n'
curl -X PUT -H "Content-Type: application/json" \
  --data @connector-config.json \
  "$CONNECT_URL/connectors/dynamodb-cdc-source/config"

# Verify connector status
printf '\nChecking connector status...\n'
curl "$CONNECT_URL/connectors/dynamodb-cdc-source/status"

printf '\nEnvironment started.\n'
