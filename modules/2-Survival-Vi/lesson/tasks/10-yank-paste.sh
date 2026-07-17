# shellcheck shell=bash disable=SC2034
TASK_TITLE="Copy & paste (yank)"
TASK_CAT="Editing"
TASK_BODY="vi calls copying 'yanking':
  yy   yank (copy) the current line
  p    paste AFTER the cursor (a yanked line pastes on the line below)
  P    paste BEFORE (the line above)
Remember dd from the delete task? It doesn't just erase — it CUTS the line into
the same buffer. So dd then p MOVES a line (you'll do that next).

dupe.txt is:
  repeat me
  other line
Duplicate the first line so the file becomes:
  repeat me
  repeat me
  other line
Put the cursor on 'repeat me', yank it (yy), then paste it below (p). :wq.
  vim dupe.txt"
TASK_TRY="vim dupe.txt"
TASK_WHY="yank/paste is how you copy config blocks, duplicate a line to tweak,
or reorder things. yy + p is the everyday combo; capital P pastes above when
you need it there instead."
TASK_HINTS=(
  "Cursor on the 'repeat me' line: press yy, then p. The copy lands on the line below. Then :wq."
  "yy copies the whole line; p drops it just beneath the cursor."
)
setup() {
  local f="$HOME/playground/dupe.txt"
  [ -e "$f" ] || printf 'repeat me\nother line\n' > "$f"
}
check() {
  local f="$HOME/playground/dupe.txt"
  [ -f "$f" ] || { fail "dupe.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
repeat me
repeat me
other line
EOF
  then
    pass "yanked a line and pasted a copy below it. That's copy/paste, vi-style."
  else
    fail "aim for 'repeat me' twice, then 'other line'"
    show_diff "$f" <<'EOF'
repeat me
repeat me
other line
EOF
    return 1
  fi
}
