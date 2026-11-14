Versions: https://github.com/n8n-io/n8n/releases



Updates:
==================================================
2026/11/14

Version set to 2.47.7

==================================================
2026/11/13 Initial installation

https://docs.n8n.io/deploy/host-n8n/install-options/install-using-docker-compose 
https://github.com/n8n-io/n8n-docs/blob/main/docs/deploy/host-n8n/install-options/install-using-docker-compose.md

Additional Settings:

1. Add to ollama environmanet
Environment="OLLAMA_HOST=0.0.0.0:11434"

2. Host LAN IP 192.168.3.100, reserved permanently in “TP-LINK ROUTER” DHCP settings

3. Use http://192.168.3.100:11434/v1  on GUI for connecting a model through Ollama.

Provider: Self-hosted or OpenAI-compatible endpoint
Base URL: http://192.168.3.100:11434/v1
API key: Leave empty for Ollama
Model: <model name on ollama list>

4. additional for network settings