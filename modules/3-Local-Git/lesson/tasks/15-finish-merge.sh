# shellcheck shell=bash disable=SC2034
TASK_TITLE="Finish the merge & read history"
TASK_CAT="Conflicts"
TASK_BODY="green has been rebased on top of main and its conflict resolved
(config.txt reads version = 3.0). Because green now sits directly on top of
main, merging it is a clean fast-forward — no conflict this time. Finish the job:
  git checkout main
  git merge green
  git log --oneline

The last command shows the whole story as one straight line. You took two
conflicting changes and ended with a clean history and the version you chose."
TASK_TRY="git merge green"
TASK_WHY="This is the payoff of rebasing before merging: the messy fork is gone,
the conflict was resolved once, and 'git log --oneline' reads top-to-bottom
like a clean narrative instead of a tangle."
TASK_HINTS=(
  "git checkout main   then   git merge green   then   git log --oneline"
  "It fast-forwards (no conflict) because green is already built on top of main. main ends at version = 3.0."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit config.txt "Add config" <<'EOF'
name = app
version = 1.0
port = 8080
EOF
  repo_commit config.txt "Set version to 2.0 (blue, merged)" <<'EOF'
name = app
version = 2.0
port = 8080
EOF
  g checkout -q -b green
  repo_commit config.txt "Set version to 3.0 (green, rebased)" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if ! on_branch main; then fail "switch to main to merge into it: git checkout main"; return 1; fi
  if g merge-base --is-ancestor green main 2>/dev/null && file_contains "$REPO/config.txt" '^version = 3\.0$'; then
    pass "green merged into main — version = 3.0, clean linear history. You resolved a conflict end to end. 🎉"
  else
    fail "on main, run: git merge green (it fast-forwards to version 3.0)"
    return 1
  fi
}
