#!/usr/bin/env bash

set -a
source "../.env"
set +a

echo "Creating bind mount paths..."
mkdir -p "$N8N_FILES_PATH"

echo "Setting up permissions..."
# main
chmod 700 ../.
chmod 600 ../.env
chmod 600 ../.env.example
chmod 600 ../compose.yaml
# scripts
chmod 700 ../scripts

echo "Set up done"