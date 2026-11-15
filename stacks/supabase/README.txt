Version update: sh update.sh
Start: docker compose up -d
Stop: docker compose down



Updates:
==================================================
2026/11/14 Compose https://supabase.com/docs/guides/self-hosting/docker

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




