# shellcheck shell=bash disable=SC2034
TASK_TITLE="Build the audited backup script"
TASK_CAT="The project"
TASK_BODY="Put it all together. Write a script at ~/playground/backup.sh that:
  1. tars + gzips a directory (use projects/) into a .tar.gz
  2. scp's that archive to backup@localhost:~/backups/
  3. checks the exit code (\$?) after EACH step and reports success/failure
Then make it executable (chmod +x) and run it.

A minimal shape:
  #!/usr/bin/env bash
  set -euo pipefail
  SRC=\"\$HOME/playground/projects\"
  ARCHIVE=\"backup-\$(date +%Y%m%d-%H%M%S).tar.gz\"
  tar czf \"/tmp/\$ARCHIVE\" -C \"\$HOME/playground\" projects
  echo \"tar exit code: \$?\"
  scp \"/tmp/\$ARCHIVE\" backup@localhost:~/backups/
  echo \"scp exit code: \$?\"
  echo \"Backup \$ARCHIVE shipped.\"

Write it your way — this is YOUR script. Then: chmod +x backup.sh && ./backup.sh"
TASK_TRY="nano ~/playground/backup.sh    # or: use your AI agent, then read every line"
TASK_WHY="This is the graded project. 'set -euo pipefail' makes the script
stop on the first error instead of charging ahead. Quote every variable
(\"\$VAR\") so a path with a space — or an empty value — can't turn a command
destructive. Read the sample-solution only AFTER your own attempt."
TASK_HINTS=(
  "Create the file, add a shebang and 'set -euo pipefail', then tar, then scp."
  "chmod +x ~/playground/backup.sh then run it with ./backup.sh from ~/playground"
  "Stuck? The full reference is in the module's sample-solution/backup.sh"
)
check() {
  local f="$HOME/playground/backup.sh"
  if ! file_exists "$f"; then fail "no ~/playground/backup.sh yet"; return 1; fi
  if ! owner_can_execute "$f"; then fail "backup.sh exists but isn't executable — chmod +x it"; return 1; fi
  if backup_has_tarball; then
    pass "backup.sh ran and a .tar.gz archive is now on the backup host. You built and shipped a real backup. 🎉"
  else
    fail "backup.sh is ready, but no .tar.gz has landed in backup@localhost:~/backups/ — run it: ./backup.sh"
    return 1
  fi
}
