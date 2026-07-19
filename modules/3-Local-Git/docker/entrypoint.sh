#!/usr/bin/env bash
# Runs as root at container start. Prepares a fresh, disposable playground and
# resets lesson progress, then drops the learner into a shell as 'dev'. Each
# lesson task rebuilds the git repo it needs via its setup().
set -euo pipefail

rm -rf /home/dev/playground
mkdir -p /home/dev/playground
chown -R dev:dev /home/dev/playground

rm -rf /home/dev/.lesson

if [ "$#" -gt 0 ]; then
  cmd="$(printf '%q ' "$@")"
  exec su - dev -c "cd ~/playground && exec $cmd"
else
  exec su - dev -c "cd ~/playground && exec bash"
fi
