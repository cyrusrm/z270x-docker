Docker setup for AI Lab

/mnt/workspace/
│
├── apps/                         # Persistent application data
│   ├── n8n-files/
│   ├── openwebui-files/
│   └── comfyui-files/
│
├── docker/                       # Docker infrastructure
│   ├── docker-root/
│   ├── stacks/
│   │   ├── automation/
│   │   │   └── n8n/
│   │   ├── ai-interface/
│   │   │   └── openwebui/
│   │   ├── search/
│   │   │   └── searxng/
│   │   └── backend/
│   │       └── supabase/
│   └── scripts/
│
├── llama/                        # Local AI experiments
│
├── projects/                     # Actual development projects
│   ├── project-alpha/
│   │   ├── .devcontainer/
│   │   │   ├── devcontainer.json
│   │   │   └── Dockerfile
│   │   ├── src/
│   │   ├── tests/
│   │   ├── README.md
│   │   └── ...
│   │
│   └── project-beta/
│       ├── .devcontainer/
│       │   └── devcontainer.json
│       └── ...
│
├── sai/                           # Personal scripts and utilities
│
└── swapfile



Installation:

1. Create a shared network bridge before running containers
$ docker network create \
  --driver bridge \
  ai_search_shared

2. Run "docker compose up -d" on each app by dependencies (searxng > openwebui > n8n)