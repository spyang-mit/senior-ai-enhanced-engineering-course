# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read a file's contents"
TASK_CAT="Navigation"
TASK_BODY="Ways to look inside a file:
  cat file      dump the whole thing
  less file     page through it (q to quit) — good for big files
  head / tail   first / last lines (tail -f follows a live log)
  wc -l file    count the lines

The server log is at logs/server.log. Count how many lines it has and
save just that number:"
TASK_TRY="wc -l < ~/playground/logs/server.log > ~/playground/answer.txt"
TASK_WHY="Using '<' feeds the file to wc on stdin, so the output is a bare
number with no filename attached — exactly what a script would want to parse."
TASK_HINTS=(
  "wc -l counts lines. Redirect the result into answer.txt."
  "Run: wc -l < ~/playground/logs/server.log > ~/playground/answer.txt"
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
