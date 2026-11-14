Docker setup for AI Lab


Installation:

1. Create a shared network bridge before running containers
$ docker network create \
  --driver bridge \
  ai_search_shared

2. Run "docker compose up -d" on each app by dependencies (searxng > openwebui > n8n)