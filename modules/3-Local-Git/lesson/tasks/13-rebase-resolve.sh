# shellcheck shell=bash disable=SC2034
TASK_TITLE="Rebase & resolve the conflict"
TASK_CAT="Conflicts"
TASK_BODY="Same collision, better approach. You're on branch 'green' (version =
3.0). main has moved to version = 2.0. Replay green on top of main:
  git rebase main

git replays green's change and hits the same conflict — config.txt now has the
markers. This time you RESOLVE it:
  1. Open it:   vim config.txt
  2. You'll see:
       <<<<<<< HEAD
       version = 2.0
       =======
       version = 3.0
       >>>>>>> Set version to 3.0 (green)
     Edit the file so the version line reads exactly  version = 3.0  and DELETE
     all three marker lines (<<<<<<<, =======, >>>>>>>). Save with :wq.
  3. Mark it resolved and continue:
       git add config.txt
       git rebase --continue
     (If vim opens with a commit message, just :wq to accept it.)

  ⚠  Finish with 'git rebase --continue' — NOT 'git commit'. Using git commit
     here quietly tangles your branch; the very next task shows you exactly why.

End state: green sits on top of main, config.txt reads version = 3.0, no markers."
TASK_TRY="git rebase main"
TASK_WHY="Resolving a conflict is just: edit the file to what you actually want,
remove the markers, 'git add' to say 'done with this file', then continue. Do
it once and it stops being scary. Choosing 3.0 here means green's change wins."
TASK_HINTS=(
  "git rebase main → then vim config.txt, make the version line 'version = 3.0' and delete the <<<<<<< ======= >>>>>>> lines, :wq → git add config.txt → git rebase --continue."
  "Stuck mid-rebase and want out? 'git rebase --abort' resets you, then 'lesson next' re-seeds and you can try again."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit config.txt "Add config" <<'EOF'
name = app
version = 1.0
port = 8080
EOF
  g checkout -q -b green
  repo_commit config.txt "Set version to 3.0 (green)" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
  g checkout -q main
  repo_commit config.txt "Set version to 2.0 (blue, merged)" <<'EOF'
name = app
version = 2.0
port = 8080
EOF
  g checkout -q green
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if rebase_in_progress; then
    fail "rebase still in progress — resolve config.txt (version = 3.0, no markers), then 'git add config.txt' and 'git rebase --continue'."; return 1
  fi
  if has_conflict_markers "$REPO/config.txt"; then
    fail "config.txt still has <<<<<<< ======= >>>>>>> markers — remove them so the version line is just 'version = 3.0'."; return 1
  fi
  if ! on_branch green; then fail "you should end up on green — git checkout green, then git rebase main"; return 1; fi
  if g merge-base --is-ancestor main green 2>/dev/null && file_is "$REPO/config.txt" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
  then
    pass "conflict resolved and green rebased onto main — config.txt reads version = 3.0, history is linear, no markers left. That's the hard part of git, done."
  else
    fail "aim for config.txt = name/version = 3.0/port, with green rebased on top of main"
    show_diff "$REPO/config.txt" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
    return 1
  fi
}
