# shellcheck shell=bash disable=SC2034
TASK_TITLE="Work on a branch (checkout -b)"
TASK_CAT="Branching"
TASK_BODY="A BRANCH is just a movable pointer to a commit — a cheap, separate
line of work. You make one so you can experiment without touching 'main'.
  git branch            list branches (you're on main)
  git checkout -b NAME  create branch NAME and switch to it in one step

Create a branch called 'feature', then make a commit on it:
  git checkout -b feature
  echo 'new feature line' >> README.md      (or edit it in vim)
  git commit -a -m \"Start the feature\"

Now 'feature' is one commit ahead of 'main', and main is untouched."
TASK_TRY="git checkout -b feature"
TASK_WHY="Branches are the reason git lets you move fast: risky work happens on
a branch, and main stays clean until you're ready. Creating one is instant —
it's just a new pointer, not a copy of your files."
TASK_HINTS=(
  "git checkout -b feature — then make a change and commit it (git commit -a -m \"...\")."
  "You need to end up ON branch 'feature' with at least one commit that main doesn't have."
)
setup() {
  repo_init_with_commit
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if ! branch_exists feature; then fail "create the branch: git checkout -b feature"; return 1; fi
  if ! on_branch feature; then fail "switch to it: git checkout feature"; return 1; fi
  if [ "$(g rev-list --count main..feature 2>/dev/null || echo 0)" -ge 1 ]; then
    pass "you're on 'feature' with a commit main doesn't have. main stays clean while you work."
  else
    fail "now commit something on feature: edit a file, then git commit -a -m \"Start the feature\""
    return 1
  fi
}
