#!/usr/bin/env bash
# Create symlink ln -sf /mnt/workspace/docker/scripts/docker-list.sh /home/sai/.local/bin/zx-docker-list
#
# Run with: zx-docker-list

docker ps -a --no-trunc --format 'table {{.Names}}\t{{.Status}}'