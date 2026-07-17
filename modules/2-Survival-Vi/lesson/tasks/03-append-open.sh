# shellcheck shell=bash disable=SC2034
TASK_TITLE="Append & open new lines"
TASK_CAT="Editing"
TASK_BODY="'i' inserts BEFORE the cursor. There are more ways into insert mode,
and picking the right one saves you a lot of arrow-key nudging:
  a   insert AFTER the cursor
  A   insert at the END of the current line
  o   open a new line BELOW and start inserting
  O   open a new line ABOVE and start inserting
(Move between lines with j/k or the arrow keys.)

Starting from:
  apples
  bananas
turn it into:
  apples
  bananas and cream
  cherries
So: put the cursor on the 'bananas' line and press A to jump to its end and
start inserting; type ' and cream'. You're STILL in insert mode now, so just
press Enter to start a new line and type 'cherries'. Then Esc and :wq.
(The 'o' key does the same 'open a line below' — but from NORMAL mode. Here
you're already inserting, so Enter is simpler.)
  vim list.txt"
TASK_TRY="vim list.txt"
TASK_WHY="A (append at end of line) and o (open a line below) are two of the most
used keys in vi. And once you're in insert mode, Enter just makes a new line
like in any editor — no need to leave insert mode to add the next line."
TASK_HINTS=(
  "On the bananas line: press A, type ' and cream', then press Enter (you're still inserting) and type 'cherries'. Then Esc and :wq."
  "A jumps to end-of-line and inserts; pressing Enter while inserting starts the next line. (From normal mode you'd press o instead.)"
)
setup() {
  local f="$HOME/playground/list.txt"
  [ -e "$f" ] || printf 'apples\nbananas\n' > "$f"
}
check() {
  local f="$HOME/playground/list.txt"
  [ -f "$f" ] || { fail "list.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
apples
bananas and cream
cherries
EOF
  then
    pass "you appended with A and started a new line without leaving insert mode. Nicely done."
  else
    fail "not quite — aim for three lines: apples / bananas and cream / cherries"
    show_diff "$f" <<'EOF'
apples
bananas and cream
cherries
EOF
    return 1
  fi
}
