# shellcheck shell=bash disable=SC2034
TASK_TITLE="Change & replace"
TASK_CAT="Editing"
TASK_BODY="Often you want to delete AND retype in one motion. These delete, then
drop you straight into insert mode:
  r<char>   replace just the character under the cursor (stays in normal mode)
  cw        change from the cursor to the end of the word, then insert
  C         change from the cursor to the end of the line, then insert
(After cw or C you're inserting — type the new text, then Esc.)

Fix fix.txt. Starting from:
  Xolor: RDE
  label: OLD TEXT HERE
make it:
  color: red
  label: fresh
So: use r to turn the leading 'X' into 'c'; use cw on 'RDE' to type 'red'; and
use C at the start of 'OLD TEXT HERE' to replace the rest of the line with
'fresh'. Esc, :wq.
  vim fix.txt"
TASK_TRY="vim fix.txt"
TASK_WHY="cw ('change word') and C ('change to end of line') are the fastest way
to fix a typo or rewrite a value — no separate delete-then-insert dance. r is
perfect for a single wrong character."
TASK_HINTS=(
  "On the X press  rc  (replace with c). On 'RDE' press  cw  then type red, Esc. On the 'O' of OLD press  C  then type fresh, Esc."
  "cw and C delete first and leave you in insert mode — just type the replacement, then Esc."
)
setup() {
  local f="$HOME/playground/fix.txt"
  [ -e "$f" ] || printf 'Xolor: RDE\nlabel: OLD TEXT HERE\n' > "$f"
}
check() {
  local f="$HOME/playground/fix.txt"
  [ -f "$f" ] || { fail "fix.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
color: red
label: fresh
EOF
  then
    pass "r, cw, and C — you fixed a char, a word, and a line's tail. Slick."
  else
    fail "aim for:  color: red  /  label: fresh"
    show_diff "$f" <<'EOF'
color: red
label: fresh
EOF
    return 1
  fi
}
