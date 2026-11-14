Versions: https://github.com/open-webui/open-webui/releases



Updates:
==================================================
2026/11/14

Deleted previous containers and volumes and created by compose
Set env version to v0.13.3

==================================================
2026/10/26 Initial installation

https://github.com/open-webui/open-webui/blob/main/TROUBLESHOOTING.md

Run openwebui via this command due to ollama access issues
docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main