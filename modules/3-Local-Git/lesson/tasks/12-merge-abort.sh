# shellcheck shell=bash disable=SC2034
TASK_TITLE="Back out safely (merge --abort)"
TASK_CAT="Conflicts"
TASK_BODY="You're sitting in the middle of the conflicted merge from the last
task. Before you back out, LOOK at the mess so you'll recognize it next time:
  git status        config.txt under 'Unmerged paths' (both modified); git even
                    says 'you have unmerged paths' and 'fix conflicts and run
                    git commit' or 'use git merge --abort to abort'
  git diff          shows the conflicting hunk, both sides, with the markers
  cat config.txt    the raw <<<<<<< ======= >>>>>>> markers in the file

Now back out completely:
  git merge --abort

And confirm it worked — run status again and see the difference:
  git status        'nothing to commit, working tree clean', back on main

--abort returns the repo to exactly how it was before you ran 'git merge' — main
at version = 2.0, no markers, nothing lost. (Next you'll take the OTHER approach:
rebase green on top of main and resolve the conflict for real.)"
TASK_TRY="git status"
TASK_WHY="'--abort' is your undo for a merge you don't want to finish right now.
Running status/diff before and after is the habit that matters: you learn to
read the 'I'm mid-conflict' state and confirm you're back to clean — so bailing
out never feels like a leap of faith."
TASK_HINTS=(
  "Look first (git status, git diff), then back out: git merge --abort, then git status again to confirm it's clean."
  "After --abort, git status says 'nothing to commit, working tree clean' and you're on main at version 2.0."
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
  g merge green >/dev/null 2>&1 || true   # leaves the repo mid-conflict
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if merge_in_progress; then
    fail "still mid-merge — back all the way out with: git merge --abort"; return 1
  fi
  if on_branch main && working_clean && file_contains "$REPO/config.txt" '^version = 2\.0$'; then
    pass "merge aborted — clean working tree, back on main at version 2.0, as if the merge never happened."
  else
    fail "run 'git merge --abort' to return to a clean main"
    return 1
  fi
}
