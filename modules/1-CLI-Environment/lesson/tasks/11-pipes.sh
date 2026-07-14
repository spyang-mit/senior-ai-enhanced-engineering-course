# shellcheck shell=bash disable=SC2034
TASK_TITLE="Pipe commands together"
TASK_CAT="Pipes & redirection"
TASK_BODY="A pipe '|' feeds one command's output into the next. Chaining
small tools is the heart of Unix. The pieces you'll need:
  grep PATTERN file    print only the lines that match PATTERN
  wc -l                count lines
  |                    send one command's output into another
  >                    redirect final output into a file

Your task: figure out how many lines in logs/server.log contain the word
ERROR, and save just that number into a file called errors.txt.

Assemble it from the pieces above. If you get stuck, 'lesson hint' will nudge
you, and give the full command if you really need it."
TASK_TRY=""
TASK_WHY="grep finds the lines; a pipe hands them to wc to count. You're
answering a real question ('how many errors?') by composing two tiny tools —
no custom program needed. Learning to build these yourself is the whole point."
TASK_HINTS=(
  "Use grep to select the ERROR lines, pipe (|) them into wc -l to count, and redirect (>) that into errors.txt."
  "Run: grep ERROR logs/server.log | wc -l > errors.txt"
)
check() {
  local f="$HOME/playground/errors.txt"
  local expected; expected=$(grep -c ERROR "$HOME/playground/logs/server.log" 2>/dev/null)
  local got; got=$(tr -dc '0-9' < "$f" 2>/dev/null)
  if [ -n "$got" ] && [ "$got" = "$expected" ]; then
    pass "$got ERROR lines — grep | wc did the work."
  else
    fail "errors.txt should hold $expected (count of ERROR lines)"; return 1
  fi
}
