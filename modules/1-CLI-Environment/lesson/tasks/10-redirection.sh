# shellcheck shell=bash disable=SC2034
TASK_TITLE="Redirect output into files"
TASK_CAT="Pipes & redirection"
TASK_BODY="Two operators that trip people up:
  >   write output to a file, REPLACING whatever was there (destructive!)
  >>  APPEND output to the end of a file (safe)

Watch '>>' add to a file without clobbering it. Do these in order:
  1. See what's in the to-do list right now:
       cat notes/todo.txt
  2. Append a new line to the end of it:
       echo 'ship the backup script' >> notes/todo.txt
  3. Look again — your line is at the bottom, the old lines are untouched:
       cat notes/todo.txt

Now contrast with '>', which OVERWRITES. Create a fresh file with one line:
  echo 'hello from the shell' > hello.txt"
TASK_TRY="cat notes/todo.txt        # then append, then cat it again to compare"
TASK_WHY="'>' silently truncates. Pointing it at the wrong file is a classic
way to erase something important — and a classic AI mistake in generated
scripts. When in doubt, reach for '>>'."
TASK_HINTS=(
  "cat the file, then '>>' to append to todo.txt, then cat again to see the change."
  "Also create hello.txt: echo 'hello from the shell' > hello.txt"
)
check() {
  local todo="$HOME/playground/notes/todo.txt" hello="$HOME/playground/hello.txt"
  if ! file_contains "$todo" "ship the backup script"; then
    fail "append the line to notes/todo.txt with >>"; return 1
  fi
  if file_contains "$hello" "hello from the shell"; then
    pass "appended to todo.txt and created hello.txt — you've got > vs >>."
  else
    fail "create hello.txt with > containing your line"; return 1
  fi
}
