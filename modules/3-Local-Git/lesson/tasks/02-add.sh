# shellcheck shell=bash disable=SC2034
TASK_TITLE="Stage a change (git add)"
TASK_CAT="Basics"
TASK_BODY="git has THREE places a file can live:
  • the WORKING TREE   — your actual files, as you edit them
  • the STAGING AREA   — changes you've marked to go into the next commit
  • the REPOSITORY     — the committed history

'git add' moves a change from the working tree into the staging area — you're
saying 'include this in my next snapshot'.

This repo has an untracked file 'notes.txt'. Stage it, then check the status:
  git add notes.txt
  git status
git status will now show notes.txt under 'Changes to be committed'."
TASK_TRY="git add notes.txt"
TASK_WHY="Staging is git's way of letting you compose a commit deliberately —
you pick exactly which changes go together. 'git add .' stages everything at
once, but naming files keeps your commits focused."
TASK_HINTS=(
  "Run: git add notes.txt   then   git status"
  "After adding, git status lists notes.txt in green under 'Changes to be committed'."
)
setup() {
  repo_reset
  g init -q -b main
  printf 'buy milk\nwalk the dog\n' > "$REPO/notes.txt"
}
check() {
  if ! is_repo; then fail "no repo here — did you jump past task 1? Run 'lesson next' to reset."; return 1; fi
  if is_staged notes.txt; then
    pass "notes.txt is staged — it's in the staging area, ready for the next commit."
  else
    fail "stage the file with: git add notes.txt"
    return 1
  fi
}
