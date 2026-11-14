Versions: https://github.com/searxng/searxng/pkgs/container/searxng/versions?filters%5Bversion_type%5D=tagged



Updates:
==================================================
2026/11/14

Made edits to compose file for overall network system coherence
Uncommented version on env file and set to 2026.11.14-a7128d5d1

==================================================
2026/10/28  https://docs.searxng.org/admin/installation-docker.html

Compose instancing
This is the recommended way to deploy SearXNG in a containerized environment. Compose templates allow you to define container configurations in a declarative manner.

Setup
Create the environment:

# Create the environment and configuration directories
$ mkdir -p ./searxng/core-config/
$ cd ./searxng/

# Fetch the latest compose template
$ curl -fsSL \
    -O https://raw.githubusercontent.com/searxng/searxng/master/container/docker-compose.yml \
    -O https://raw.githubusercontent.com/searxng/searxng/master/container/.env.example
Copy the .env.example file and edit the values as needed:

$ cp -i .env.example .env

# nano or your preferred text editor...
$ nano .env
Start & stop the services:

$ docker compose up -d
$ docker compose down
Setup your settings in core-config/settings.yml according to your preferences.
