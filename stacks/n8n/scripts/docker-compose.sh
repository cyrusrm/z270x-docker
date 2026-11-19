#!/usr/bin/env bash
# Create symlink ln -sf /mnt/workspace/docker/stacks/n8n/scripts/docker-compose.sh /home/sai/.local/bin/d-n8n
#
# Run with: d-n8n

COMPOSE_FILE="/mnt/workspace/docker/stacks/n8n/compose.yaml"

if [[ "$1" == "up" ]]; then
    docker compose -f "$COMPOSE_FILE" up -d
elif [[ "$1" == "down" ]]; then
    docker compose -f "$COMPOSE_FILE" down
else
    echo "incorrect cmd"
fi
