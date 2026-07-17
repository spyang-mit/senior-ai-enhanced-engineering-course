#!/usr/bin/env bash
# Runs as root at container start. Prepares a fresh, disposable playground and
# resets lesson progress, then drops the learner into a shell as 'dev'.
set -euo pipefail

# Fresh playground every run. Each lesson task seeds its own file via setup().
rm -rf /home/dev/playground
mkdir -p /home/dev/playground
chown -R dev:dev /home/dev/playground

# Reset guided-lesson progress.
rm -rf /home/dev/.lesson

# Hand control to the learner as 'dev', starting in the playground. With
# arguments, run them (shell-quoted so cd + argument boundaries survive) —
# used for testing and one-offs like: docker run IMAGE lesson map
if [ "$#" -gt 0 ]; then
  cmd="$(printf '%q ' "$@")"
  exec su - dev -c "cd ~/playground && exec $cmd"
else
  exec su - dev -c "cd ~/playground && exec bash"
fi
