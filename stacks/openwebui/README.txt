Versions: https://github.com/open-webui/open-webui/releases
Start: docker compose up -d
Stop: docker compose down

Initial Setup:
==================================================
1. Inspect .env.example and correct configurations except secret and keys.
2. Copy .env.example to .env
3. Generate needed keys (openssl rand -base64 32) for env
4. Run scripts/setup.sh
5. Start docker

Updates:
==================================================
2026/11/19 Re-setup

Updated mount path for openwebui-data

Generate secret key
  openssl rand -base64 32

Removed openwebui data bind mount, changed to named volume

Add permission and compose scripts

==================================================
2026/11/14

Deleted previous containers and volumes and created by compose
Set env version to v0.13.3

In gui set websearch 
websearch: toggle enable
engine: searxng
searxng query url: http://searxng-core:8081/search

==================================================
2026/10/26 Initial installation

https://github.com/open-webui/open-webui/blob/main/TROUBLESHOOTING.md

Run openwebui via this command due to ollama access issues
docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main