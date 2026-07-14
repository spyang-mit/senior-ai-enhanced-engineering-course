# shellcheck shell=bash disable=SC2034
TASK_TITLE="Copy files over ssh with scp"
TASK_CAT="Moving bytes: scp"
TASK_BODY="scp copies files between machines over the same secure ssh channel.
The syntax mirrors cp, but a remote side looks like user@host:path
  scp file.txt user@host:~/dest/     local -> remote
  scp -r dir   user@host:~/dest/     a whole directory (needs -r)
  scp user@host:~/f.txt .            remote -> local

Your task: copy your whole notes directory to the backup host — into ~/backups
on backup@localhost."
TASK_TRY=""
TASK_WHY="scp is the simplest way to 'move bytes to another machine', and it
inherits ssh's security and your key. Your backup-script project ends with an
scp exactly like this to ship the archive off the box."
TASK_HINTS=(
  "It's like cp, but the destination is user@host:path. Use -r for a directory."
  "Run: scp -r notes backup@localhost:~/backups/"
)
check() {
  if backup_has "backups/notes"; then
    pass "your notes landed in backup@localhost:~/backups/notes — copied over ssh."
  else
    fail "I don't see ~/backups/notes on the backup host yet"; return 1
  fi
}
