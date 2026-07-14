#!/usr/bin/env bash
# Runs as root when the container starts. Sets up a real ssh target, seeds a
# FRESH playground every run, resets lesson progress, then drops the learner
# into an interactive shell as the unprivileged 'dev' user.
set -euo pipefail

# 1. Start the ssh daemon (the scp/ssh tasks connect to backup@localhost).
/usr/sbin/sshd

# 2. Give 'dev' a key and authorize it on the 'backup' account, so scp/ssh are
#    passwordless — exactly how real key-based auth works.
if [ ! -f /home/dev/.ssh/id_ed25519 ]; then
  install -d -o dev -g dev -m 700 /home/dev/.ssh
  su - dev -c "ssh-keygen -t ed25519 -N '' -C 'dev@sandbox' -f ~/.ssh/id_ed25519 -q"
  su - dev -c "printf 'Host localhost\n    StrictHostKeyChecking accept-new\n    UserKnownHostsFile ~/.ssh/known_hosts\n' > ~/.ssh/config"
  su - dev -c "chmod 600 ~/.ssh/config ~/.ssh/id_ed25519"

  install -d -o backup -g backup -m 700 /home/backup/.ssh
  install -o backup -g backup -m 600 /home/dev/.ssh/id_ed25519.pub /home/backup/.ssh/authorized_keys
  install -d -o backup -g backup -m 755 /home/backup/backups
fi

# 3. Seed a fresh, disposable playground. Wreck it freely; re-enter to reset.
rm -rf /home/dev/playground
cp -r /opt/playground-seed /home/dev/playground

# Build the archive the tar-extract task unpacks.
install -d -o dev -g dev /home/dev/playground/archive
tar czf /home/dev/playground/archive/oldlogs.tar.gz -C /opt oldlogs-src

# Known starting permission states the lesson depends on.
chmod 644 /home/dev/playground/scripts/deploy.sh   # task: chmod u+x
chmod 644 /home/dev/playground/shared/report.txt   # task: chmod g+w,o-r
chmod 644 /home/dev/playground/secret.env          # task: chmod 600
chmod 755 /home/dev/playground/bin/greet           # task: put on PATH
chown -R dev:dev /home/dev/playground

# 4. Reset guided-lesson progress for a clean start.
rm -rf /home/dev/.lesson

# 5. Hand control to the learner as 'dev', starting in the playground.
#    With arguments, run them as 'dev' instead (used for testing and for
#    one-off commands like: docker run --rm IMAGE lesson map).
if [ "$#" -gt 0 ]; then
  exec su - dev -c "cd ~/playground && $*"
else
  exec su - dev -c "cd ~/playground && exec bash"
fi
