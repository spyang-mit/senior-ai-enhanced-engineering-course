#!/usr/bin/env bash
# Runs as root at container start. Starts the contacts API in the background,
# seeds a fresh playground (with a copy of the API spec to reference), resets
# lesson progress, then drops the learner into a shell as 'dev'.
set -euo pipefail

install -d -o dev -g dev /home/dev/.server

# Fresh playground, with the OpenAPI spec handy for reading and referencing.
rm -rf /home/dev/playground
mkdir -p /home/dev/playground
cp /opt/app/contacts-api.yaml /home/dev/playground/contacts-api.yaml
chown -R dev:dev /home/dev/playground

rm -rf /home/dev/.lesson

# Start the contacts API in the background. setsid detaches it into its own
# session so it keeps running for the whole sandbox session.
su dev -c "ACCESS_LOG=/home/dev/.server/access.log APP_DIR=/opt/app \
  setsid python3 /opt/app/server.py >/home/dev/.server/server.out 2>&1 < /dev/null &"
sleep 0.5   # let it bind :8080 before the learner starts

if [ "$#" -gt 0 ]; then
  cmd="$(printf '%q ' "$@")"
  exec su - dev -c "cd ~/playground && exec $cmd"
else
  exec su - dev -c "cd ~/playground && exec bash"
fi
