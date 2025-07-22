# DynamoDB CDC Local Environment

This repository provides a Docker Compose setup and helper scripts for testing DynamoDB Change Data Capture (CDC) locally on macOS. It uses Confluent Platform containers together with `amazon/dynamodb-local` and deploys the official **DynamoDB CDC Source Connector** in Kafka Connect.

## Files

- `docker-compose.yml` - defines Zookeeper, Kafka broker, Schema Registry, Kafka Connect, and DynamoDB Local.
- `connector-config.json` - connector configuration in *SNAPSHOT_CDC* mode.
- `start.sh` - launches the environment, creates a DynamoDB table with streams enabled, and deploys the connector.
- `stop.sh` - stops the environment and removes volumes.

## Prerequisites

- Docker must be installed and running.
- AWS CLI should be available for managing the local DynamoDB instance.

## Usage

```bash
./start.sh   # start services and deploy connector
./stop.sh    # tear down
```

The connector publishes change events from `TestTable` to the Kafka topic `dynamodb.cdc`.
