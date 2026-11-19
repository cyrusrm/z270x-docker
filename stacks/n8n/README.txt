Versions: https://github.com/n8n-io/n8n/releases
Start: docker compose up -d
Stop: docker compose down
Generate keys: openssl rand -base64 32



Updates:
==================================================
2026/11/19 Re-setup

Regenerate keys
  openssl rand -base64 32

Check network bridge
  Check bridge: 
    $ ls /proc/sys/net/bridge/
  If no such file or directory, run: 
    $ sudo modprobe br_netfilter
  Should get: 
    $ ls /proc/sys/net/bridge/
    bridge-nf-call-arptables  bridge-nf-filter-pppoe-tagged
    bridge-nf-call-ip6tables  bridge-nf-filter-vlan-tagged
    bridge-nf-call-iptables   bridge-nf-pass-vlan-input-dev
  Save permanently
    $ echo br_netfilter | sudo tee /etc/modules-load.d/br_netfilter.conf

Setup permissions:
  ./script-setup-permissions.sh

Run compose up


==================================================
2026/11/15 some error on sandbox

Could not finish setup but was fixed after waiting for sometime

Here's what most likely happened.
1. The runner registered before it became healthy
Remember this earlier log?
runner registration stream established
runner registration heartbeat sent
runner registered
healthy=false

At that moment:
- The runner had connected to the API.
- It had sent its registration heartbeat.
- But the API still considered it unhealthy.
Later, we queried the registry and got:
{
  "healthy": true,
  "cordoned": false,
  "capacity_total": 1000
}

The runner had become healthy without a restart.
This suggests the runner's readiness state and its registration state weren't synchronized immediately during startup.

2. Why it eventually worked
There are two important mechanisms here:
  1. Runner preparation: The runner starts, initializes its Docker runtime, prepares the sandbox image, and checks readiness.
  2. Heartbeat updates: The runner periodically sends its current health and capacity information to the API.
The API uses those heartbeat updates to decide whether a runner is eligible for new sandbox workloads. 
GitHub+1

Your earlier healthy=false was likely an initial state during preparation. Once the runner became ready and reported that state through a subsequent heartbeat, the API changed it to healthy=true.
The sandbox test then succeeded because the API finally had an eligible runner.

3. What this means for your setup
Setup completed
You now have:
- n8n 2.47.7 running through Docker Compose.
- Task runners working.
- Sandbox API 1.15.0 running.
- Sandbox runner 1.15.0 registered and healthy.
- Local Ollama connected.
- AI Assistant Code Sandbox successfully tested.
My recommendation: Leave your current configuration alone. No additional restart, Kubernetes deployment, or certificate regeneration is necessary.


Added script check-n8n.sh
# Background:
# During initial startup, the sandbox runner may register with the API before
# it is considered healthy and eligible to execute sandbox tasks.
# This startup delay can cause temporary sandbox initialization failures,
# particularly when bringing up the stack from a clean state.
#
# Run this script after starting the Docker Compose stack.
# Wait until all checks report PASS before using n8n Code nodes,
# to ensure the sandbox API and runner are ready.


==================================================
2026/11/15 found a bug that crashes n8n-sandbox-runner-1-1

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

Setup

2. Add a code sandbox
    - select "n8n sandbox"
    - set service url: http://sandbox-api:8080
    - set API key: copied from env N8N_SANDBOX_SERVICE_API_KEY


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