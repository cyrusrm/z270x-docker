#!/usr/bin/env bash

# create shared netword
docker network create --driver bridge ai_apps_shared

# create docker root folder
mkdir ../docker-root

# set permissions
chmod 700 ../scripts
chmod 700 ../stacks
