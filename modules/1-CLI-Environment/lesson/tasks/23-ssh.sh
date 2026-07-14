# shellcheck shell=bash disable=SC2034
TASK_TITLE="Connect over ssh"
TASK_CAT="Moving bytes: ssh"
TASK_BODY="ssh gives you a shell on another machine, securely. This sandbox
runs its own ssh server and a second account called 'backup', so you can
practice for real against 'backup@localhost'.

An ssh KEY PAIR has already been set up for you: a private key in
~/.ssh/id_ed25519 (keep secret, it's 600) and a public key that's been
installed on the backup account. Run a single command on the backup host:
  ssh backup@localhost hostname
(You can also just 'ssh backup@localhost' to get a shell — type 'exit' to
come back.)"
TASK_TRY="ssh backup@localhost hostname"
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
