#!/usr/bin/env bash

echo "Setting up permissions..."
# main
chmod 700 ../.
# scripts
chmod 700 ../scripts
# supabase project
chmod 700 ../supabase-project
chmod 600 ../supabase-project/.env
chmod 600 ../supabase-project/.env.example
chmod 600 ../supabase-project/docker-compose.yml

echo "Set up done"