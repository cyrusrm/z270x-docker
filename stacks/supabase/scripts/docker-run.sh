#!/usr/bin/env bash
# Create symlink ln -sf /mnt/workspace/docker/stacks/supabase/scripts/docker-run.sh /home/sai/.local/bin/d-supabase
#
# Run with: d-supabase

RUN_FILE="/mnt/workspace/docker/stacks/supabase/supabase-project/run.sh"

if [[ "$1" == "up" ]]; then
    sh $RUN_FILE start
elif [[ "$1" == "down" ]]; then
    sh $RUN_FILE stop
else
    echo "incorrect cmd"
fi
