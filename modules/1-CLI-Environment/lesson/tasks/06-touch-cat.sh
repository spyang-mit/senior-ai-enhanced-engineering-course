# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create and read files"
TASK_CAT="Files"
TASK_BODY="Two workhorse commands:
  touch file      create an empty file — or, if it exists, update its timestamp
  cat file        print a file's contents to the screen
  cat a b > c     join files a and b into c ('cat' is short for concatenate)

Create an empty scratch file, then read your to-do list:
  touch scratch.txt
  cat notes/todo.txt"
TASK_TRY="touch scratch.txt"
TASK_WHY="'touch' is the fastest way to make a file exist (scripts use it as a
marker/flag); 'cat' is the fastest way to see a short file's contents. For
anything long, use 'less' (from the last task) so you can page and search."
TASK_HINTS=(
  "touch creates the file; cat prints one."
  "Run: touch scratch.txt   then   cat notes/todo.txt"
)
check() {
  if file_exists "$HOME/playground/scratch.txt"; then
    pass "scratch.txt exists (created by touch). Did 'cat' show your to-do list?"
  else
    fail "create scratch.txt with touch"
    return 1
  fi
}
