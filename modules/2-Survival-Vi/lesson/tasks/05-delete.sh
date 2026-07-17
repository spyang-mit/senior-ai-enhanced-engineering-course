# shellcheck shell=bash disable=SC2034
TASK_TITLE="Delete text"
TASK_CAT="Editing"
TASK_BODY="Deleting, all from normal mode:
  x     delete the single character under the cursor
  dw    delete from the cursor to the end of the word
  dd    delete the WHOLE line
  D     delete from the cursor to the end of the line
Many commands take a COUNT in front — 2dd deletes two lines, 3x deletes three
characters. (Handy fact: a deleted line is also 'cut' — you'll paste it later.)

Clean up cleanup.txt. Starting from:
  apple
  DELETE ME
  bananaX
  DELETE ME TOO
  cherry
make it:
  apple
  banana
  cherry
So: delete the two 'DELETE ME' lines (dd on each), and remove the stray 'X' at
the end of 'bananaX' (put the cursor on the X and press x). Esc, :wq.
  vim cleanup.txt"
TASK_TRY="vim cleanup.txt"
TASK_WHY="dd (delete line) and x (delete char) are your erasers, and counts like
3dd make them fast. Because dd also CUTS the line into a buffer, delete is half
of 'move a line' — which you'll finish in the yank/paste tasks."
TASK_HINTS=(
  "Put the cursor on a 'DELETE ME' line and press dd; repeat for the other one. For the stray X, land on it and press x."
  "To reach the end of 'bananaX' quickly: on that line press \$ to jump to the last character, then x."
)
setup() {
  local f="$HOME/playground/cleanup.txt"
  [ -e "$f" ] || printf 'apple\nDELETE ME\nbananaX\nDELETE ME TOO\ncherry\n' > "$f"
}
check() {
  local f="$HOME/playground/cleanup.txt"
  [ -f "$f" ] || { fail "cleanup.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
apple
banana
cherry
EOF
  then
    pass "junk lines gone (dd) and the stray character removed (x). Clean."
  else
    fail "aim for exactly three lines: apple / banana / cherry"
    show_diff "$f" <<'EOF'
apple
banana
cherry
EOF
    return 1
  fi
}
