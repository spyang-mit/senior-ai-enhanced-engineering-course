# shellcheck shell=bash disable=SC2034
TASK_TITLE="Merge a branch (git merge)"
TASK_CAT="Branching"
TASK_BODY="When a branch's work is ready, you MERGE it back into main. This repo
already has a 'feature' branch that added a file; main hasn't changed since.

Switch to main and merge feature into it:
  git checkout main
  git merge feature

Because main didn't move, git can just slide main's pointer forward to include
feature's commit — that's a 'fast-forward' merge (no extra merge commit). Run
'git log --oneline' afterward to see feature's commit now on main."
TASK_TRY="git merge feature"
TASK_WHY="Merge is how work rejoins the main line. When only one side moved, it's
a clean fast-forward. When BOTH main and the branch have new commits, git makes
a 'merge commit' to tie them together — and sometimes a conflict (coming soon)."
TASK_HINTS=(
  "git checkout main   then   git merge feature"
  "You merge INTO the branch you're on, so switch to main first, then merge feature."
)
setup() {
  repo_init_with_commit
  g checkout -q -b feature
  repo_commit feature.txt "Add the feature file" <<< "feature content"
  g checkout -q main
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if ! on_branch main; then fail "be on main to merge into it: git checkout main"; return 1; fi
  if g merge-base --is-ancestor feature main 2>/dev/null && [ -f "$REPO/feature.txt" ]; then
    pass "feature is merged into main — feature.txt is here and its commit is in main's history."
  else
    fail "merge it in: git merge feature (while on main)"
    return 1
  fi
}
