# shellcheck shell=bash disable=SC2034
TASK_TITLE="Pipe commands together"
TASK_CAT="Pipes & redirection"
TASK_BODY="A pipe '|' feeds one command's output into the next. Chaining
small tools is the heart of Unix:
  grep PATTERN file    print matching lines
  wc -l                count lines
  grep ERROR log | wc -l    count how many lines matched

The server log has some ERROR lines. Count them and save the number:"
TASK_TRY="grep ERROR ~/playground/logs/server.log | wc -l > ~/playground/errors.txt"
TASK_WHY="grep finds the lines; the pipe hands them to wc to count. You just
answered a real question ('how many errors?') by composing two tiny tools —
no custom program needed."
TASK_HINTS=(
  "grep ERROR ... pipes into wc -l, redirected into errors.txt."
  "Run the exact command under 'Try:'."
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
