# shellcheck shell=bash disable=SC2034
TASK_TITLE="Capstone: branch, rebase, resolve, merge"
TASK_CAT="Capstone"
TASK_BODY="No step-by-step this time — you've done every piece. Put them together.

The repo has a tiny script, greeting.sh. You're on branch 'feature', where it
was reworded to:
  echo \"hello from the feature branch\"
Meanwhile main changed the SAME line to:
  echo \"hi there\"

Goal: get feature's version onto main with a clean, linear history — so that at
the end, on main, greeting.sh reads exactly:
  echo \"hello from the feature branch\"

The path you know: rebase feature onto main, resolve the conflict in favour of
feature's line (delete the markers), continue the rebase, then merge feature
into main. When 'git log --oneline' shows one straight line and greeting.sh has
the feature wording, you're done."
TASK_TRY="git rebase main"
TASK_WHY="This is the everyday senior-engineer loop: work on a branch, keep it
current by rebasing onto main, resolve any collisions deliberately, and merge a
clean result. You can now do it without hand-holding."
TASK_HINTS=(
  "On feature: git rebase main → fix greeting.sh (keep the feature line, remove <<<<<<< ======= >>>>>>>), :wq → git add greeting.sh → git rebase --continue."
  "Then land it on main: git checkout main → git merge feature. Final greeting.sh: echo \"hello from the feature branch\"."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit greeting.sh "Add greeting script"        <<< 'echo "hi"'
  g checkout -q -b feature
  repo_commit greeting.sh "Reword greeting (feature)"  <<< 'echo "hello from the feature branch"'
  g checkout -q main
  repo_commit greeting.sh "Tweak greeting (main)"      <<< 'echo "hi there"'
  g checkout -q feature
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if rebase_in_progress; then fail "finish the rebase: resolve greeting.sh, git add greeting.sh, git rebase --continue."; return 1; fi
  if has_conflict_markers "$REPO/greeting.sh"; then fail "remove the <<<<<<< ======= >>>>>>> markers from greeting.sh — keep the feature line."; return 1; fi
  if ! on_branch main; then fail "finish on main: git checkout main, then git merge feature"; return 1; fi
  if g merge-base --is-ancestor feature main 2>/dev/null && file_is "$REPO/greeting.sh" <<'EOF'
echo "hello from the feature branch"
EOF
  then
    pass "capstone complete — feature's change is on main with a clean linear history, conflict resolved your way. You own local git now."
  else
    fail "aim for greeting.sh = echo \"hello from the feature branch\" on main, with feature rebased and merged in"
    return 1
  fi
}
