#!/usr/bin/env bash

echo "Setting up permissions..."
# this project folders
chmod 700 ../.
chmod 700 ../scripts
# this project files
chmod 600 ../.env
chmod 600 ../.env.example
chmod 600 ../compose.yaml

echo "Set up done"