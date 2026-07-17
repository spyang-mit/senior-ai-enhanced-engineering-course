# shellcheck shell=bash disable=SC2034
TASK_TITLE="Move a line (cut & paste)"
TASK_CAT="Editing"
TASK_BODY="Since dd CUTS a line into the buffer, moving a line is just cut then
paste:
  dd   cut the line
  p    paste it below a target line   (or P to paste above)

order.txt is out of order:
  second
  first
  third
Move 'first' above 'second' so it reads:
  first
  second
  third
One way: put the cursor on 'first' and press dd (it's now cut). The cursor is
on 'third'; press k to go up to 'second', then P to paste ABOVE it. :wq.
  vim order.txt"
TASK_TRY="vim order.txt"
TASK_WHY="Reordering lines — moving an import to the top, a function up a block —
is a constant editing job, and dd + p/P does it without ever selecting text
with a mouse."
TASK_HINTS=(
  "On 'first' press dd. Now go to the 'second' line and press P (paste above). Then :wq."
  "dd removes 'first' and holds it; P pastes it back above the line you're on. Land on 'second' before pressing P."
)
setup() {
  local f="$HOME/playground/order.txt"
  [ -e "$f" ] || printf 'second\nfirst\nthird\n' > "$f"
}
check() {
  local f="$HOME/playground/order.txt"
  [ -f "$f" ] || { fail "order.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
first
second
third
EOF
  then
    pass "you cut a line with dd and pasted it into place — that's how you reorder in vi."
  else
    fail "aim for first / second / third, in that order"
    show_diff "$f" <<'EOF'
first
second
third
EOF
    return 1
  fi
}
