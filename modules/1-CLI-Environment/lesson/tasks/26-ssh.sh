# shellcheck shell=bash disable=SC2034
TASK_TITLE="Connect over ssh"
TASK_CAT="Moving bytes: ssh"
TASK_BODY="ssh gives you a secure shell on another machine. The form is:
  ssh user@host            open a shell on the remote machine
  ssh user@host <command>  run ONE command there, then come back

This sandbox runs its own ssh server and a second account called 'backup', and
an ssh KEY PAIR is already set up for you (private key ~/.ssh/id_ed25519, mode
600; the matching public key is installed on the backup account) — so logging
in to backup@localhost just works, no password.

Your task: connect to backup@localhost and run a command there that prints the
remote host's name. (Plain 'ssh backup@localhost' gives you an interactive
shell instead; type 'exit' to return.)"
TASK_TRY=""
TASK_WHY="Key-based auth (no passwords) is how every deploy, git push, and
server login actually works. The key is why it's passwordless; the file
permissions on that key are why ssh trusts it. Config lives in ~/.ssh/config."
TASK_HINTS=(
  "user@host, then optionally a command to run remotely."
  "Run: ssh backup@localhost hostname"
)
check() {
  if backup_host_reachable; then
    pass "you can ssh to backup@localhost with your key — no password needed."
  else
    fail "couldn't reach backup@localhost over ssh yet; try: ssh backup@localhost hostname"; return 1
  fi
}
