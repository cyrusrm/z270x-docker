Version update: sh update.sh   (updating and rollback https://supabase.com/docs/guides/self-hosting/docker#updating)
Start: sh run.sh start
Stop: sh run.sh stop
Access: http://supabase-envoy:8000



Updates:
==================================================
2026/11/19 Re-setup

1. Re download files
https://supabase.com/docs/guides/self-hosting/docker#manual-installation

git clone --depth 1 --branch self-hosted/v0.8.4 https://github.com/supabase/supabase
cp -rf supabase/docker/. supabase-project
cd supabase-project && cp .env.example .env
printf 'ref=self-hosted/v0.8.4\n' > .supabase-version

2. Confirm conflicts
Resolve only networks
Removed data bind mount and remained default

3. Pull images
docker compose pull

4. Process keys
sh utils/generate-keys.sh
sh utils/add-new-auth-keys.sh

5. Start (warning! finish keys setup before running)
sh run.sh start


Cleanup (had to cleanup since unhealthy. ran first without keys)
sh reset.sh

volume error delete permission fix:
1. Stop the containers:bash
docker compose down -v
Use code with caution.
2. Remove the contents via a temporary container:bash
docker run --rm -v "$(pwd)/volumes/db:/db" alpine rm -rf /db/data
Use code with caution.
3. Verify the folder is gone and confirm reset successful
ls -la ./volumes/db
sh reset.sh

Restart from pulling images

==================================================
2026/11/15 Set local settings on docker compose

1 SET MOUNT VOLUMES

  # Storage
  storage:
    volumes:
      - ${APP_FILES_PATH}/supabase/storage:/var/lib/storage:z

  # Imgproxy
  imgproxy:
    volumes:
      - ${APP_FILES_PATH}/supabase/storage:/var/lib/storage:z

  # Database
  db:
    volumes:
      - ${APP_FILES_PATH}/supabase/db-data:/var/lib/postgresql/data:Z


2 SET NETWORK SETTINGS

  api-gw:
    networks:
      default:
        aliases:
          - envoy
          - kong
      ai_apps_shared: {}

networks:
  default:
    name: supabase_default

  ai_apps_shared:
    external: true
    name: ai_apps_shared

3 ADD TO ENV FILE

APP_FILES_PATH=/mnt/workspace/app


==================================================
2026/11/15 Compose https://supabase.com/docs/guides/self-hosting/docker

# Get the code
git clone --depth 1 --branch self-hosted/v0.8.4 https://github.com/supabase/supabase

# Make your new supabase project directory
mkdir supabase-project

# Tree should look like this
# .
# ├── supabase
# └── supabase-project

# Copy the configuration to your project
cp -rf supabase/docker/. supabase-project

# Switch to the project directory and create a .env from the example
cd supabase-project && cp .env.example .env

# Record the base version so update.sh can upgrade this install later
printf 'ref=self-hosted/v0.8.4\n' > .supabase-version

# Pull the latest images
docker compose pull

# Generate keys and secrets To generate secure passwords and secrets, run:
sh utils/generate-keys.sh

# As the next step, use the following script to add the new API keys and asymmetric key pair:
sh utils/add-new-auth-keys.sh




