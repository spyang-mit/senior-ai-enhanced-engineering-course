# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the history (git log)"
TASK_CAT="Basics"
TASK_BODY="'git log' shows the commit history, newest first — each with its
author, date, unique hash (id), and message. It can be verbose, so there's a
compact form:
  git log            full history
  git log --oneline  one short line per commit (hash + message)

This repo has some history. Have a look, then answer a question with it: how
many commits are there? Count them and save just the number:
  git log --oneline | wc -l > count.txt

(That pipes the one-line-per-commit output into wc -l, which counts lines.)"
TASK_TRY="git log --oneline"
TASK_WHY="History is git's whole point — 'git log' is how you see what happened
and grab a commit's hash (you'll need those hashes for cherry-pick and rebase).
--oneline is the view you'll live in day to day."
TASK_HINTS=(
  "Run: git log --oneline    then    git log --oneline | wc -l > count.txt"
  "The number in count.txt should equal how many commits git log shows."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit README.md "Initial commit"          <<< "hello"
  repo_commit app.py    "Add the app entrypoint"   <<< "print('hi')"
  repo_commit notes.txt "Write down some notes"     <<< "notes"
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  local expected got
  expected="$(commit_count)"
  got="$(tr -dc '0-9' < "$REPO/count.txt" 2>/dev/null)"
  if [ -n "$got" ] && [ "$got" = "$expected" ]; then
    pass "$got commits — you read the log and counted the history."
  else
    fail "count.txt should hold $expected (the number of commits). Try: git log --oneline | wc -l > count.txt"
    return 1
  fi
}
