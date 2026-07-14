# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read exit codes"
TASK_CAT="Shell scripting"
TASK_BODY="Every command returns an exit code: 0 means success, anything else
means failure. The shell stores the last one in \$?
  ls /real/dir ; echo \$?     -> 0
  ls /nope     ; echo \$?     -> nonzero
You chain on it:
  cmd1 && cmd2    run cmd2 only if cmd1 SUCCEEDED
  cmd1 || cmd2    run cmd2 only if cmd1 FAILED

Run a command that fails, capture its exit code to a file:
  ls /does/not/exist 2>/dev/null ; echo \$? > ~/playground/code.txt"
TASK_TRY="ls /does/not/exist 2>/dev/null ; echo \$? > ~/playground/code.txt"
TASK_WHY="Exit codes are how scripts know whether a step worked. Your backup
project will check \$? after tar and after scp so it can report real success
or failure instead of blindly claiming 'done'. '2>/dev/null' throws away the
error message by redirecting stderr."
TASK_HINTS=(
  "Run any failing command, then: echo \$? > ~/playground/code.txt"
  "Run the exact command under 'Try:'."
)
check() {
  local f="$HOME/playground/code.txt"
  local code; code=$(tr -dc '0-9' < "$f" 2>/dev/null)
  if [ -n "$code" ] && [ "$code" != "0" ]; then
    pass "captured a nonzero exit code ($code) — that's a failure signal a script can act on."
  else
    fail "code.txt should hold the NONZERO exit code of a failed command"; return 1
  fi
}
