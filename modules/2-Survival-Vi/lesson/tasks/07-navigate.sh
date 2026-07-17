# shellcheck shell=bash disable=SC2034
TASK_TITLE="Navigate by word — and fix as you go"
TASK_CAT="Navigation"
TASK_BODY="Editing is mostly about getting the cursor to the right spot fast. In
normal mode, without touching the arrow keys:
  h  j  k  l    left, DOWN, UP, right
  w  /  b       jump FORWARD / BACK by a whole word
  0  /  \$       jump to the START / END of the line
Chain them: a few w's fly across a long line; j/k change lines; b hops back a
word when you overshoot.

Open navigate.txt — the file itself tells you the job: leave the FIRST line
alone, but everywhere else turn each '<>' into a single '!'. The lines are long
on purpose, so use w and b to reach each '<>' instead of holding down l.

To turn a '<>' into '!' (with x and r from the last two tasks): land the cursor
on the '<' and press x to delete it — now the cursor sits on the '>' — then
press r! to replace it with '!'. You never leave normal mode, so you can jump
straight to the next '<>' and repeat. Save with :wq when they're all fixed.
  vim navigate.txt"
TASK_TRY="vim navigate.txt"
TASK_WHY="This is what real editing feels like: hop to a spot with w/b, make a
tiny fix with x/r, hop to the next. vi's whole idea is that movement and edits
share one keyboard — no reaching for the mouse or the arrow keys."
TASK_HINTS=(
  "For each '<>': put the cursor on the '<', press x (deletes '<'), then r! (replaces the '>' with '!'). Fly between them with w; press b if you overshoot."
  "There are five '<>' to fix — on lines 2, 3, and 5. The '<>' on line 1 must stay: that line tells you not to touch it."
)
setup() {
  local f="$HOME/playground/navigate.txt"
  [ -e "$f" ] || cat > "$f" <<'EOF'
Don't modify this line, but for all others, replace each instance of <> with ! instead.
Why did the chicken cross the road?<> It does not matter<>
<>#/bin/sh is commonly used at the top of executable scripts<>
Did you fly between words using "w" and "b" to reach each one?
That was great<> Yes?
EOF
}
check() {
  local f="$HOME/playground/navigate.txt"
  [ -f "$f" ] || { fail "navigate.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
Don't modify this line, but for all others, replace each instance of <> with ! instead.
Why did the chicken cross the road?! It does not matter!
!#/bin/sh is commonly used at the top of executable scripts!
Did you fly between words using "w" and "b" to reach each one?
That was great! Yes?
EOF
  then
    pass "every '<>' became '!' (and you left line 1 alone). You navigated by word and fixed as you went — that's fluent vi."
  else
    fail "not there yet — replace each '<>' with '!' on lines 2, 3, and 5, and leave line 1 untouched"
    show_diff "$f" <<'EOF'
Don't modify this line, but for all others, replace each instance of <> with ! instead.
Why did the chicken cross the road?! It does not matter!
!#/bin/sh is commonly used at the top of executable scripts!
Did you fly between words using "w" and "b" to reach each one?
That was great! Yes?
EOF
    return 1
  fi
}
