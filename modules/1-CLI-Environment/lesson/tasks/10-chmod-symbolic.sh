# shellcheck shell=bash disable=SC2034
TASK_TITLE="Tune group & other permissions"
TASK_CAT="Permissions"
TASK_BODY="shared/report.txt is currently rw-r--r-- (644): owner can edit,
everyone can read. You want your teammates (group) to be able to EDIT it,
and you want to stop the general public (others) from reading it.

  chmod g+w file    add write for group
  chmod o-r file    remove read from others
  chmod o+r file    (the opposite — add read for others)

You can combine them: chmod g+w,o-r file"
TASK_TRY="chmod g+w,o-r ~/playground/shared/report.txt"
TASK_WHY="Permissions are how Unix answers 'who can touch this?' A file that's
world-readable when it shouldn't be is a real security leak — and invisible
until someone finds it."
TASK_HINTS=(
  "You need group write ON and others read OFF. End state is rw-rw---- (660)."
  "Run: chmod g+w,o-r ~/playground/shared/report.txt"
)
check() {
  local f="$HOME/playground/shared/report.txt"
  if mode_is "$f" 660; then
    pass "now $(symbolic_mode_of "$f") (660): group can edit, others are locked out."
  else
    fail "mode is $(symbolic_mode_of "$f") ($(mode_of "$f")); aim for rw-rw---- (660)"; return 1
  fi
}
