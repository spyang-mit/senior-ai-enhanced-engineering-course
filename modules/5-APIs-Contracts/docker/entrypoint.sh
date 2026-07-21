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

# Copy initial handler stubs from the workspace mount (if mounted) or from
# the reference server's seed directory. The host mount at /home/dev/workspace
# is where the learner's code lives; if it exists, use it. Otherwise seed
# from the image's seed directory.
if [ -d /home/dev/workspace/handlers ]; then
  echo "workspace/ mounted — using host-side handler files"
else
  echo "workspace/ not mounted — seeding fresh stubs from image"
  mkdir -p /home/dev/workspace/handlers
  if [ -d /opt/server/handlers ]; then
    cp -r /opt/server/handlers/* /home/dev/workspace/handlers/
  fi
  # Also seed the contract YAML
  cp /opt/server/orders-api.yaml /home/dev/workspace/orders-api.yaml 2>/dev/null || true
fi

chown -R dev:dev /home/dev/playground /home/dev/workspace

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
