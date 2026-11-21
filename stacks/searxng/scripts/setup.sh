#!/usr/bin/env bash

echo "Setting up permissions..."
# main
chmod 700 ../.
chmod 600 ../.env
chmod 600 ../.env.example
chmod 600 ../compose.yaml
# scripts
chmod 700 ../scripts

echo "Set up done"