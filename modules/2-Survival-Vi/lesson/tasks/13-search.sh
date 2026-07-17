# shellcheck shell=bash disable=SC2034
TASK_TITLE="Search for text"
TASK_CAT="Navigation"
TASK_BODY="To find text instead of hunting for it:
  /word  + Enter   search FORWARD for 'word'; the cursor jumps to the match
  n                jump to the NEXT match
  N                jump to the PREVIOUS match
(There's also ?word to search backward.) Search + change is a killer combo.

notes.txt has two 'TODO' markers:
  alpha
  bravo
  charlie TODO fix this
  delta
  echo TODO and this
  foxtrot
Change BOTH 'TODO' to 'DONE'. Search with /TODO, use cw to type DONE, press n
to jump to the next TODO, and cw again. Esc, :wq. Result:
  ... charlie DONE fix this ...
  ... echo DONE and this ...
  vim notes.txt"
TASK_TRY="vim notes.txt"
TASK_WHY="In a real file you don't scroll looking for something — you /search for
it. Combined with cw (change word) you can fix every occurrence of a name or a
typo in seconds; n hops you to each one."
TASK_HINTS=(
  "Type /TODO and Enter. On the match press cw, type DONE, Esc. Press n for the next TODO, then cw DONE Esc again. Then :wq."
  "After Esc, n repeats your last search forward — no need to retype /TODO."
)
setup() {
  local f="$HOME/playground/notes.txt"
  [ -e "$f" ] || printf 'alpha\nbravo\ncharlie TODO fix this\ndelta\necho TODO and this\nfoxtrot\n' > "$f"
}
check() {
  local f="$HOME/playground/notes.txt"
  [ -f "$f" ] || { fail "notes.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
alpha
bravo
charlie DONE fix this
delta
echo DONE and this
foxtrot
EOF
  then
    pass "found both TODOs with /search and n, and changed each with cw. That's the pro move."
  else
    fail "both 'TODO' should become 'DONE'; leave everything else as-is"
    show_diff "$f" <<'EOF'
alpha
bravo
charlie DONE fix this
delta
echo DONE and this
foxtrot
EOF
    return 1
  fi
}
