# shellcheck shell=bash disable=SC2034
TASK_TITLE="Replay work on top (git rebase)"
TASK_CAT="History"
TASK_BODY="While you worked on 'feature', 'main' moved on — someone added a
commit. Your branches have now DIVERGED. You could merge, but rebase gives a
cleaner, straight-line history: it takes your feature commits and replays them
on top of the latest main, as if you'd branched just now.

You're on 'feature'. Rebase it onto main:
  git rebase main

main added main.txt; your feature added feat.txt — different files, so this
rebases cleanly with no conflict. Run 'git log --oneline' after and notice the
history is one straight line, with your commit on top."
TASK_TRY="git rebase main"
TASK_WHY="merge vs. rebase: merge preserves the fork and adds a merge commit;
rebase rewrites your branch to sit on top of the target, giving a linear
history that's easier to read. (Rebase local work; don't rebase shared history.)"
TASK_HINTS=(
  "You're already on feature — just run: git rebase main"
  "After it, 'git log --oneline' shows main's commit then yours, in a straight line (main is now an ancestor of feature)."
)
setup() {
  repo_init_with_commit
  g checkout -q -b feature
  repo_commit feat.txt "Feature work" <<< "feature"
  g checkout -q main
  repo_commit main.txt "Main work" <<< "main"
  g checkout -q feature
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if rebase_in_progress; then fail "the rebase is paused — finish it, or 'git rebase --abort' and try again."; return 1; fi
  if ! on_branch feature; then fail "do this on feature: git checkout feature, then git rebase main"; return 1; fi
  if g merge-base --is-ancestor main feature 2>/dev/null && [ -f "$REPO/feat.txt" ] && [ -f "$REPO/main.txt" ]; then
    pass "feature is rebased onto main — main's commit is now underneath yours in a single straight line."
  else
    fail "replay your work on top of main: git rebase main"
    return 1
  fi
}
