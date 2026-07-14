# shellcheck shell=bash disable=SC2034
TASK_TITLE="Redirect output into files"
TASK_CAT="Pipes & redirection"
TASK_BODY="Two operators that trip people up:
  >   write output to a file, REPLACING whatever was there (destructive!)
  >>  APPEND output to the end of a file (safe)

First, append a line to your to-do list without clobbering it:
  echo 'ship the backup script' >> ~/playground/notes/todo.txt
Then create a fresh file with a single line:
  echo 'hello from the shell' > ~/playground/hello.txt"
TASK_TRY="echo 'ship the backup script' >> ~/playground/notes/todo.txt"
TASK_WHY="'>' silently truncates. Pointing it at the wrong file is a classic
way to erase something important — and a classic AI mistake in generated
scripts. When in doubt, reach for '>>'."
TASK_HINTS=(
  "Do both: >> to append to todo.txt, then > to create hello.txt."
  "echo 'hello from the shell' > ~/playground/hello.txt"
)
check() {
  local todo="$HOME/playground/notes/todo.txt" hello="$HOME/playground/hello.txt"
  if ! file_contains "$todo" "ship the backup script"; then
    fail "append the line to notes/todo.txt with >>"; return 1
  fi
  if file_contains "$hello" "hello from the shell"; then
    pass "appended to todo.txt and created hello.txt — you've got > vs >>."
  else
    fail "create ~/playground/hello.txt with > containing your line"; return 1
  fi
}
