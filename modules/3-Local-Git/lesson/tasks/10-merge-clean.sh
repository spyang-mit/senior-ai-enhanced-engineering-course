# shellcheck shell=bash disable=SC2034
TASK_TITLE="Two branches, one file (merge #1)"
TASK_CAT="Conflicts"
TASK_BODY="Now the interesting part. This repo has a config.txt, and TWO branches
each changed the SAME line of it:
  • branch 'blue'  set  version = 2.0
  • branch 'green' set  version = 3.0
main still has the original  version = 1.0.

Merging the FIRST branch is easy, because main hasn't changed. On main, merge
blue in:
  git merge blue

That's a clean fast-forward — main now reads version = 2.0. (Next task you'll
try to merge green too... and that's where it gets interesting.)"
TASK_TRY="git merge blue"
TASK_WHY="A merge is only clean when the two sides didn't touch the same lines.
blue and main didn't collide (main was untouched), so this just works. Hold
that thought — green changed the very same line blue did."
TASK_HINTS=(
  "You're on main already. Run: git merge blue"
  "Afterward, 'cat config.txt' shows version = 2.0."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit config.txt "Add config" <<'EOF'
name = app
version = 1.0
port = 8080
EOF
  g checkout -q -b blue
  repo_commit config.txt "Set version to 2.0 (blue)" <<'EOF'
name = app
version = 2.0
port = 8080
EOF
  g checkout -q main
  g checkout -q -b green
  repo_commit config.txt "Set version to 3.0 (green)" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
  g checkout -q main
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if ! on_branch main; then fail "be on main: git checkout main"; return 1; fi
  if g merge-base --is-ancestor blue main 2>/dev/null && file_contains "$REPO/config.txt" '^version = 2\.0$'; then
    pass "blue is merged — main now reads version = 2.0. Clean, because main hadn't changed that line."
  else
    fail "merge the first branch in: git merge blue (while on main)"
    return 1
  fi
}
