# shellcheck shell=bash disable=SC2034
TASK_TITLE="Insert text, then save"
TASK_CAT="Editing"
TASK_BODY="To actually TYPE text you must leave normal mode and enter INSERT
mode:
  press  i        start inserting (you'll see -- INSERT -- at the bottom)
  type your text
  press  Esc      go back to normal mode when you're done
Then save and quit:
  :wq  + Enter    write (save) and quit

greeting.txt is empty. Open it, switch to insert mode, type exactly this line:
  Hello, vi!
then Esc and save with :wq.
  vim greeting.txt"
TASK_TRY="vim greeting.txt"
TASK_WHY="Normal mode is for moving and commanding; insert mode is for typing.
The whole trick to vi is knowing which mode you're in — the -- INSERT --
indicator (bottom-left) tells you. Esc always takes you back to safety."
TASK_HINTS=(
  "Open the file, press i, type  Hello, vi!  , press Esc, then type :wq and Enter."
  "If letters trigger weird jumps, you're in normal mode — press i first to insert."
)
setup() {
  local f="$HOME/playground/greeting.txt"
  [ -e "$f" ] || : > "$f"   # start empty
}
check() {
  local f="$HOME/playground/greeting.txt"
  [ -f "$f" ] || { fail "greeting.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
Hello, vi!
EOF
  then
    pass "you inserted a line and saved it with :wq — that's the core edit loop."
  else
    fail "the file should contain exactly one line: Hello, vi!"
    show_diff "$f" <<'EOF'
Hello, vi!
EOF
    return 1
  fi
}
