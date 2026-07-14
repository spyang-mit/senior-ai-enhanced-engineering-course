# shellcheck shell=bash disable=SC2034
TASK_TITLE="Change a file's group"
TASK_CAT="Permissions"
TASK_BODY="Permissions are meaningless without knowing WHO owns a file. Every
file has an owner (a user) and a group.
  chown user file      change the owning user (usually needs root)
  chgrp group file     change the owning group
  chown user:group f   change both at once

Your task: you belong to a group called 'teammates' (run 'groups' to see).
Hand shared/report.txt to that group, so the group-write permission you set
earlier actually applies to your teammates."
TASK_TRY=""
TASK_WHY="Group-write (from the last task) only helps if the file is owned by
the RIGHT group. Ownership + permission bits work together — miss either and
access silently breaks."
TASK_HINTS=(
  "Run 'groups' to confirm you're in 'teammates', then chgrp it."
  "Run: chgrp teammates shared/report.txt"
)
check() {
  local f="$HOME/playground/shared/report.txt"
  if group_is "$f" teammates; then
    pass "report.txt now belongs to group '$(group_of "$f")'."
  else
    fail "group is '$(group_of "$f")'; change it to teammates"; return 1
  fi
}
