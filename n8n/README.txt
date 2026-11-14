Versions: https://github.com/n8n-io/n8n/releases



Updates:
==================================================
2026/11/15

found a bug that crashes n8n-sandbox-runner-1-1

Sandbox runner is failing because its Docker-in-Docker daemon cannot access a Linux kernel networking setting.
The runner uses Docker-in-Docker (privileged: true), and its internal Docker daemon expects the Linux bridge netfilter setting to be available.
The error even suggests a workaround:
    DOCKER_IGNORE_BR_NETFILTER_ERROR=1

Tried loading it manually using:
    sudo modprobe br_netfilter
It worked,  n8n-sandbox-runner-1-1 is not restarting anymore

FIX:
To make it persistent, create a module-load configuration:
    echo br_netfilter | sudo tee /etc/modules-load.d/br_netfilter.conf
Verify:
    cat /etc/modules-load.d/br_netfilter.conf
On the next reboot, systemd will load the module automatically.
Verify after reboot
    docker compose ps --format 'table {{.Names}}\t{{.Service}}\t{{.Status}}'
    lsmod | grep br_netfilter
    sysctl net.bridge.bridge-nf-call-iptables


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