# shellcheck shell=bash disable=SC2034
TASK_TITLE="See a diff, then commit -a"
TASK_CAT="Basics"
TASK_BODY="This repo already has one commit and a tracked file, notes.txt. Let's
change it, look at exactly what changed, and commit in one step.

  1. Edit notes.txt — add a line. Quickest: use vim (vim notes.txt, o, type a
     line, Esc, :wq), or  echo 'ship it' >> notes.txt
  2. git diff        — shows your UNSTAGED changes, line by line (+ added, - removed)
  3. git commit -a -m \"Update notes\"

'-a' automatically stages every TRACKED file that changed, so you skip the
separate 'git add'. (It does NOT pick up brand-new untracked files — those
still need git add.)"
TASK_TRY="git diff"
TASK_WHY="'git diff' is how you review your own work before committing — read it
every time. 'commit -a' is the fast path once files are already tracked; new
files are the exception that still need an explicit add."
TASK_HINTS=(
  "Add a line to notes.txt, run 'git diff' to see it, then: git commit -a -m \"Update notes\""
  "You need a SECOND commit and a clean working tree afterward. -a stages the modified tracked file for you."
)
setup() {
  repo_reset
  g init -q -b main
  printf 'buy milk\nwalk the dog\n' > "$REPO/notes.txt"
  g add -A; g commit -q -m "Add project notes"
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if [ "$(commit_count)" -lt 2 ]; then
    fail "make a second commit: change notes.txt, then 'git commit -a -m \"Update notes\"'"
    return 1
  fi
  if ! working_clean; then
    fail "you committed, but the working tree isn't clean — commit or discard the leftover change (git status shows it)."
    return 1
  fi
  pass "two commits now, working tree clean. 'commit -a' staged your tracked change and committed it in one go."
}
