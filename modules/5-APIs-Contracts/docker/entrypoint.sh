#!/usr/bin/env bash
# Runs as root at container start. Seeds the mounted ~/workspace (only files that
# are missing, so we never clobber the learner's work), starts the naive orders
# API (:8080) and the demo websocket (:8081), then drops the learner into a
# shell as 'dev' inside the workspace.
set -euo pipefail

WS=/home/dev/workspace

install -d -o dev -g dev /home/dev/.server
mkdir -p "$WS/handlers" "$WS/capstone"

# --- seed the workspace (seed-if-missing) ----------------------------------
cp -n /opt/app/orders-api.yaml "$WS/orders-api.yaml"    2>/dev/null || true
cp -n /opt/app/ws-listen.py     "$WS/ws-listen.py"      2>/dev/null || true
for f in /opt/lesson/handlers-seed/*.py; do
  b="$(basename "$f")"
  [ "$b" = "capstone-refund.py" ] && continue
  cp -n "$f" "$WS/handlers/$b"                          2>/dev/null || true
done
cp -n /opt/lesson/handlers-seed/capstone-refund.py "$WS/capstone/refund.py" 2>/dev/null || true

# Make the workspace editable from the host (any uid) AND from the container's
# 'dev' user, without fighting uid mismatches on Linux bind mounts.
chmod -R a+rwX "$WS" 2>/dev/null || true

# Fresh lesson progress each run (state is inside the container, not the mount).
rm -rf /home/dev/.lesson

# --- start the servers ------------------------------------------------------
su dev -c "setsid python3 /opt/app/reference-server.py >/home/dev/.server/api.out 2>&1 < /dev/null &"
su dev -c "setsid python3 /opt/app/ws-server.py        >/home/dev/.server/ws.out  2>&1 < /dev/null &"
sleep 0.5   # let :8080 bind before the learner starts

if [ "$#" -gt 0 ]; then
  cmd="$(printf '%q ' "$@")"
  exec su - dev -c "cd ~/workspace && exec $cmd"
else
  exec su - dev -c "cd ~/workspace && exec bash"
fi
