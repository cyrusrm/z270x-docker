#!/usr/bin/env bash
# Create symlink ln -sf /mnt/workspace/docker/scripts/docker-list.sh /home/sai/.local/bin/d-list
#
# Run with: d-list

docker ps -a --no-trunc --format 'table {{.Names}}\t{{.Status}}'