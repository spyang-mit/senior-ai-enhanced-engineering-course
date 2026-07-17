# shellcheck shell=bash disable=SC2034
TASK_TITLE="Jump across the file"
TASK_CAT="Navigation"
TASK_BODY="For big files you don't crawl line by line:
  gg    jump to the FIRST line
  G     jump to the LAST line
  :N    jump to line number N   (e.g. :5 goes to line 5, then Enter)
(The line numbers down the left margin help you aim.)

lines.txt has eight lines. You start on line 1, so the interesting jump is to
the far end first:
  • press G to jump to the LAST line, and append '  END' to it
  • then press gg to jump back to the FIRST line, and append '  TOP' to it
So line 8 becomes 'line 8 END' and line 1 becomes 'line 1 TOP'. Esc and :wq.
  vim lines.txt"
TASK_TRY="vim lines.txt"
TASK_WHY="gg and G are how you teleport to the top and bottom — indispensable in
a long log or a big source file. :N drops you on an exact line, which is
exactly how a stack trace or compiler error tells you where to look."
TASK_HINTS=(
  "G then A, type ' END', Esc. Then gg then A, type ' TOP', Esc. Then :wq."
  "G = bottom, gg = top. A appends at the end of whatever line you're on."
)
setup() {
  local f="$HOME/playground/lines.txt"
  [ -e "$f" ] || printf 'line 1\nline 2\nline 3\nline 4\nline 5\nline 6\nline 7\nline 8\n' > "$f"
}
check() {
  local f="$HOME/playground/lines.txt"
  [ -f "$f" ] || { fail "lines.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
line 1 TOP
line 2
line 3
line 4
line 5
line 6
line 7
line 8 END
EOF
  then
    pass "you tagged the first line (gg) and the last line (G). You can teleport now."
  else
    fail "only line 1 (→ 'line 1 TOP') and line 8 (→ 'line 8 END') should change"
    show_diff "$f" <<'EOF'
line 1 TOP
line 2
line 3
line 4
line 5
line 6
line 7
line 8 END
EOF
    return 1
  fi
}
