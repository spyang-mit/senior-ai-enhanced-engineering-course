# shellcheck shell=bash disable=SC2034
TASK_TITLE="The rebase trap: --continue, not commit"
TASK_CAT="Conflicts"
TASK_BODY="Here's the mistake that burns almost everyone once. During a rebase
conflict you resolve the file, 'git add' it, and then — out of habit — run
'git commit'. WRONG. That quietly wrecks your branch.

To make it stick, this task has ALREADY made that mistake for you. Run:
  git status
and read carefully. You'll see two alarming things:
  • 'interactive rebase in progress' — the rebase never finished
  • you're on a 'detached HEAD', NOT on branch green

What happened: during a rebase you're not on your branch, you're on a temporary
detached HEAD. 'git commit' made a commit THERE — your 'green' branch label
never moved and the rebase is still half-done. If you switched branches now,
that commit would be orphaned and effectively lost. THIS is how people 'lose'
work to rebase.

Recover the right way — finish the rebase:
  git rebase --continue

git picks up the commit you made and finally moves 'green' to it. Check the
result: git branch --show-current, git log --oneline.

(The other escape hatch is 'git rebase --abort' to throw the whole rebase away
and start over. Either is fine — the cardinal rule is simply: never end a rebase
with 'git commit'. Always 'git add' then 'git rebase --continue'.)"
TASK_TRY="git status"
TASK_WHY="Burn this in: mid-rebase you are on a detached HEAD, so 'git commit'
does NOT advance your branch or finish the rebase. The correct finish is always
'git rebase --continue' (after 'git add'). Now you've seen the broken state, so
you'll recognize it instantly if you ever slip."
TASK_HINTS=(
  "Run 'git status' to see the mess, then recover with: git rebase --continue"
  "Goal: end up back ON branch green, rebase finished. 'git rebase --continue' does it; 'git rebase --abort' would instead undo the whole rebase."
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
  # start the rebase, resolve the conflict, then MAKE THE CLASSIC MISTAKE:
  # 'git commit' instead of 'git rebase --continue' -> detached HEAD, rebase unfinished
  g rebase main >/dev/null 2>&1 || true
  printf 'name = app\nversion = 3.0\nport = 8080\n' > "$REPO/config.txt"
  g add config.txt
  GIT_EDITOR=true g commit >/dev/null 2>&1 || true
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if rebase_in_progress; then
    fail "the rebase is still unfinished (that's the trap). Finish it properly with: git rebase --continue"; return 1
  fi
  if ! on_branch green; then
    fail "you're not back on 'green'. If you aborted, redo it: git rebase main, resolve config.txt to version = 3.0, git add config.txt, git rebase --continue."; return 1
  fi
  if g merge-base --is-ancestor main green 2>/dev/null && file_is "$REPO/config.txt" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
  then
    pass "recovered — 'git rebase --continue' finished the rebase and moved green onto main. You've now seen the detached-HEAD trap and the fix. Never end a rebase with git commit."
  else
    fail "green should be rebased onto main with config.txt at version = 3.0. Finish the rebase with 'git rebase --continue' (not git commit)."
    return 1
  fi
}
