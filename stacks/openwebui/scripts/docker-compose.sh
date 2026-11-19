#!/usr/bin/env bash
# Create symlink ln -sf /mnt/workspace/docker/stacks/openwebui/scripts/docker-compose.sh /home/sai/.local/bin/d-openwebui
#
# Run with: d-openwebui

COMPOSE_FILE="/mnt/workspace/docker/stacks/openwebui/compose.yaml"

if [[ "$1" == "up" ]]; then
    docker compose -f "$COMPOSE_FILE" up -d
elif [[ "$1" == "down" ]]; then
    docker compose -f "$COMPOSE_FILE" down
else
    echo "incorrect cmd"
fi
