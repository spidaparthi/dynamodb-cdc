#!/usr/bin/env bash
# Stop and remove Docker Compose environment
set -euo pipefail

COMPOSE_FILE="docker-compose.yml"

printf '\nStopping and removing containers...\n'
docker compose -f "$COMPOSE_FILE" down -v

printf 'Environment stopped.\n'
