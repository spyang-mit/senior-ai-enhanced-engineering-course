# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read a file's contents"
TASK_CAT="Navigation"
TASK_BODY="Ways to look inside a file:
  cat file      dump the whole thing
  less file     page through it (q to quit) — good for big files
  head / tail   first / last lines (tail -f follows a live log)
  wc -l file    count the lines

Work up to counting the log's lines, one step at a time. Run each of these
and watch what it does:

  1. View the whole file:
       cat logs/server.log
  2. Count its lines directly:
       wc -l logs/server.log          # prints: <count> logs/server.log
  3. Do the same thing with a PIPE — '|' feeds cat's output straight into wc
     (you'll dig into pipes in a couple of tasks):
       cat logs/server.log | wc -l    # prints just: <count>
  4. Finally, save just the number to a file so 'lesson check' can verify it:
       wc -l < logs/server.log > answer.txt"
TASK_TRY="cat logs/server.log        # then work down to: wc -l < logs/server.log > answer.txt"
TASK_WHY="Notice three ways to feed a file to a command: as an argument
(wc -l file), through a pipe (cat file | wc -l), and via stdin redirection
(wc -l < file). That last one gives a bare number with no filename attached —
exactly what a script wants to parse, which is why we save it that way."
TASK_HINTS=(
  "Try each line in the task in order: cat, then wc -l, then the pipe."
  "The one that gets checked: wc -l < logs/server.log > answer.txt"
)
check() {
  local f="$HOME/playground/answer.txt"
  local expected; expected=$(wc -l < "$HOME/playground/logs/server.log" 2>/dev/null | tr -d ' ')
  local got; got=$(tr -dc '0-9' < "$f" 2>/dev/null)
  if [ -n "$got" ] && [ "$got" = "$expected" ]; then
    pass "$got lines — correct."
  else
    fail "answer.txt should contain $expected (the line count of server.log)"
    return 1
  fi
}
