#!/usr/bin/env bash
# Runs as root at container start. Seeds a fresh playground with the contract
# YAML, initial handler stubs, and starts the server. Drops into a shell as 'dev'.
set -euo pipefail

install -d -o dev -g dev /home/dev/.server

# Fresh playground with the contract and handler workspace.
rm -rf /home/dev/playground
mkdir -p /home/dev/playground/handlers

# Copy the contract YAML into the playground for reference.
cp /opt/server/orders-api.yaml /home/dev/playground/orders-api.yaml 2>/dev/null || true

# Copy the contract YAML into the workspace too, so the learner has it on host.
# If workspace is mounted, the host already has it — this is a safety seed.
mkdir -p /home/dev/workspace
cp /opt/server/orders-api.yaml /home/dev/workspace/orders-api.yaml 2>/dev/null || true

# Try chown, but don't fail on macOS-style bind mounts where chown of a
# mounted volume can fail. The server runs as 'dev' via su, so permissions
# matter only for the playground (which is owned by dev).
chown -R dev:dev /home/dev/playground 2>/dev/null || true
chown -R dev:dev /home/dev/.server 2>/dev/null || true
# chown on workspace/ is best-effort — bind mounts on macOS may refuse it.
chown -R dev:dev /home/dev/workspace 2>/dev/null || true

rm -rf /home/dev/.lesson

# Start the orders API in the background.
su dev -c "ACCESS_LOG=/home/dev/.server/access.log \
  setsid python3 /opt/server/reference-server.py >/home/dev/.server/server.out 2>&1 < /dev/null &"
sleep 0.5   # let it bind :8080 before the learner starts

if [ "$#" -gt 0 ]; then
  cmd="$(printf '%q ' "$@")"
  exec su - dev -c "cd ~/playground && exec $cmd"
else
  exec su - dev -c "cd ~/playground && exec bash"
fi
