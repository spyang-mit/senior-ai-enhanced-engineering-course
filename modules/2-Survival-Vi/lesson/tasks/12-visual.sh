# shellcheck shell=bash disable=SC2034
TASK_TITLE="Select a block (visual mode)"
TASK_CAT="Editing"
TASK_BODY="So far you've copied and moved WHOLE lines (yy, dd). To grab a CUSTOM
range — part of a line, or several lines — use VISUAL mode: you mark a start,
move to mark the end, and the text highlights as you go.
  v        start selecting character by character (mark start; move to mark end)
  V        start selecting whole LINES at a time
  <motion> extend the highlight with motions you know (h l w b, or j/k for V)
Then act on the highlighted block:
  y        yank (copy) it
  d        delete (cut) it
  p        paste it after the cursor   (P pastes before)

move.txt is:
  Move the word between the brackets: [WIDGET]
  Drop it into these empty brackets: []
CUT 'WIDGET' out of the first brackets and paste it into the empty second ones:
  Move the word between the brackets: []
  Drop it into these empty brackets: [WIDGET]

Do it: put the cursor on the 'W', press v, then e to extend the highlight to
the end of the word, then d to cut it. Now go down to line 2 (j), press \$ to
reach the end and h to land on the '[', and press p to paste. Then :wq.
  vim move.txt"
TASK_TRY="vim move.txt"
TASK_WHY="Visual mode is how you cut and paste an arbitrary chunk — a phrase, a
few lines of a function, a config block — not just a whole line. Mark it, y to
copy or d to cut, move, then p. It's click-and-drag done from the keyboard."
TASK_HINTS=(
  "Line 1: cursor on the W, press v, press e (WIDGET highlights), press d (cuts it). Line 2: press j, then \$ then h to land on the empty '[', then press p."
  "v marks a character selection; e extends to the end of the word; d cuts (y would COPY instead); p pastes after the cursor."
)
setup() {
  local f="$HOME/playground/move.txt"
  [ -e "$f" ] || printf 'Move the word between the brackets: [WIDGET]\nDrop it into these empty brackets: []\n' > "$f"
}
check() {
  local f="$HOME/playground/move.txt"
  [ -f "$f" ] || { fail "move.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
Move the word between the brackets: []
Drop it into these empty brackets: [WIDGET]
EOF
  then
    pass "you selected a custom block with visual mode, cut it, and pasted it elsewhere. That's the whole trick."
  else
    fail "aim for: line 1 ends with '[]' and line 2 ends with '[WIDGET]'"
    show_diff "$f" <<'EOF'
Move the word between the brackets: []
Drop it into these empty brackets: [WIDGET]
EOF
    return 1
  fi
}
