# shellcheck shell=bash disable=SC2034
TASK_TITLE="Make a script executable"
TASK_CAT="Permissions"
TASK_BODY="Every file has permission bits for three classes of people:
  u = user (the owner)   g = group   o = others (everyone else)
and three permissions: r = read, w = write, x = execute.

'chmod' changes them. Symbolic form is chmod <who><+/-><perms>:
  chmod u+x file    give the owner execute
  chmod g-w file    take write away from the group

scripts/deploy.sh can't run — it has no execute bit. Give its owner one:"
TASK_TRY="chmod u+x ~/playground/scripts/deploy.sh"
TASK_WHY="'permission denied' when running a script is the #1 invisible shell
bug, and AI constantly generates a script then forgets the +x. Now you'll
recognize it instantly."
TASK_HINTS=(
  "'u' is the owner, '+x' adds execute."
  "Run: chmod u+x ~/playground/scripts/deploy.sh"
)
check() {
  local f="$HOME/playground/scripts/deploy.sh"
  file_exists "$f" || { fail "can't find $f"; return 1; }
  if owner_can_execute "$f"; then
    pass "owner can now execute deploy.sh — mode is $(symbolic_mode_of "$f") ($(mode_of "$f"))"
  else
    fail "still not executable by owner — mode is $(symbolic_mode_of "$f")"; return 1
  fi
}
