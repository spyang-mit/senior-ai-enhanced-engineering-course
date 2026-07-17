# shellcheck shell=bash disable=SC2034
TASK_TITLE="Undo & redo"
TASK_CAT="Editing"
TASK_BODY="Made a mistake? vi remembers:
  u        undo the last change (press it again and again to go further back)
  Ctrl-R   redo (undo the undo)
This is why you can experiment fearlessly — nothing is committed until you save,
and even then u walks it back.

story.txt starts as:
  It was a dark and stormy night.
  The end.
Do this in order:
  1. append '  Or was it?' to the end of the FIRST line (A)
  2. delete the SECOND line with dd
  3. realize you wanted to keep it — press u to UNDO just that deletion
The first line stays edited; 'The end.' comes back. Save with :wq. Result:
  It was a dark and stormy night. Or was it?
  The end.
  vim story.txt"
TASK_TRY="vim story.txt"
TASK_WHY="u is your safety net — it turns 'oh no' into a non-event. Notice it
undoes one change at a time, so the earlier edit you wanted to keep stays put
while the mistake is rolled back."
TASK_HINTS=(
  "On line 1: A, type ' Or was it?', Esc. Then dd on line 2. Then press u once to bring 'The end.' back. Then :wq."
  "u undoes ONE change. You made two edits and undo only the second (the dd)."
)
setup() {
  local f="$HOME/playground/story.txt"
  [ -e "$f" ] || printf 'It was a dark and stormy night.\nThe end.\n' > "$f"
}
check() {
  local f="$HOME/playground/story.txt"
  [ -f "$f" ] || { fail "story.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
It was a dark and stormy night. Or was it?
The end.
EOF
  then
    pass "you edited line 1, deleted line 2, then undid just the deletion. That's u working one step at a time."
  else
    fail "aim for line 1 = 'It was a dark and stormy night. Or was it?' and line 2 = 'The end.' (brought back with u)"
    show_diff "$f" <<'EOF'
It was a dark and stormy night. Or was it?
The end.
EOF
    return 1
  fi
}
