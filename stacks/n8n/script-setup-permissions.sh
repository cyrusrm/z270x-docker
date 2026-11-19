
#!/usr/bin/env bash
#
# Set COMPOSE_SERVICE to the target service in compose.yaml.
# Run this script from its stack folder.
#

set -euo pipefail

# ==============================
#       Load stack .env
# ==============================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f .env ]]; then
    echo "ERROR: .env file not found."
    exit 1
fi

set -a
source .env
set +a

# ==============================
#  Set target Compose service
# ==============================

COMPOSE_SERVICE="n8n"

if [[ -z "$COMPOSE_SERVICE" ]]; then
    echo "ERROR: COMPOSE_SERVICE not set."
    exit 1
fi

# ==============================
#          Get IDs
# ==============================

# Detect container's effective UID
CONTAINER_UID="$(docker compose run --rm --no-deps \
    --entrypoint id "$COMPOSE_SERVICE" -u)"

if [[ ! "$CONTAINER_UID" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Could not determine container UID."
    exit 1
fi

# Current host identity
HOST_UID="$(id -u)"
HOST_USER="$(id -un)"

# Verify rootless Docker
if ! docker info --format '{{json .SecurityOptions}}' 2>/dev/null \
    | grep -q 'rootless'; then
    echo "ERROR: Rootless Docker not detected."
    exit 1
fi

# Calculate mapped host UID
if (( CONTAINER_UID == 0 )); then
    MAPPED_UID="$HOST_UID"
else
    SUBUID_START="$(awk -F: -v user="$HOST_USER" \
        '$1 == user {print $2; exit}' /etc/subuid)"

    if [[ ! "$SUBUID_START" =~ ^[0-9]+$ ]]; then
        echo "ERROR: No valid subordinate UID range found."
        exit 1
    fi

    MAPPED_UID=$((SUBUID_START + CONTAINER_UID - 1))
fi

echo "Compose service: $COMPOSE_SERVICE"
echo "Container UID:   $CONTAINER_UID"
echo "Host UID:        $HOST_UID"
echo "Host user:       $HOST_USER"
echo "Mapped UID:      $MAPPED_UID"

# ==============================
#          Set ACL
# ==============================

ROOT="/mnt/workspace"

set_permission() {
    local dir="$1"

    # Check if:
    # 1. dir starts with ROOT (and is a subdirectory, not ROOT itself)
    # 2. dir does not end with '/'
    if ! [[ "$dir" == "$ROOT/"* && "$dir" != */ ]]; then
        echo "Error: '$dir' is not valid"
        exit 1
    fi

    # Create dir
    mkdir -p "$dir"

    # Set working ACL
    echo
    echo "Configuring: $dir"
    
    sudo setfacl -m "u:$MAPPED_UID:rwx" "$dir"
    sleep 1
    sudo setfacl -m "d:u:$MAPPED_UID:rwx" "$dir"
    sleep 1
    echo "  rwx  $dir"

    # Set traverse access ACL
    while [[ "$dir" != "$ROOT" ]]; do
        dir="${dir%/*}"
        sudo setfacl -m "u:$MAPPED_UID:--x" "$dir"
        echo "  --x  $dir"
        sleep 1
    done
}

# ==============================
#       Prepare directories
# ==============================

: "${N8N_DATA_PATH:?N8N_DATA_PATH missing in .env}"
: "${N8N_FILES_PATH:?N8N_FILES_PATH missing in .env}"

N8N_DATA_PATH=/mnt/workspace/docker/docker-data/n8n-data
N8N_FILES_PATH=/mnt/workspace/apps/n8n-files

set_permission "$N8N_DATA_PATH"
set_permission "$N8N_FILES_PATH"

echo
echo "Permissions configured successfully for $COMPOSE_SERVICE."
