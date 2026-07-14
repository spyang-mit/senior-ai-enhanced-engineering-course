# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the manual (man)"
TASK_CAT="Getting help"
TASK_BODY="Every command comes with a manual. 'man' opens it:
  man ls          the manual for ls
  man man         the manual about man itself
  ls --help       a shorter summary many commands also offer

The manual opens in a pager. Practice these navigation keys (they also work in
'less' and 'git log'):
  Space / b        page down / page up
  Ctrl-f / Ctrl-b  forward / back a screen (f=forward, b=back)
  /word  then n    search for 'word', jump to next match
  q                quit back to your shell

Open the manual for ls, and while you're in there, try searching: type
/reverse and Enter to jump to the -r flag. Then press q to quit."
TASK_TRY="man ls        # /reverse to search, Space to page, q to quit"
TASK_WHY="The manual is the offline, always-correct source of truth — reach
for it before guessing or googling. (These pager keys are a gentle preview of
vi-style navigation; Module 2 teaches survival vi for writing git commit
messages.)"
TASK_HINTS=(
  "Just run 'man ls'. Inside, type /reverse then Enter to search; press q to quit."
  "Run: man ls   (then q to get back to your shell)"
)
check() {
  # Verify they actually opened the ls manual, by looking in shell history
  # (the sandbox flushes history after every command).
  if history_has 'man[[:space:]]+ls\b'; then
    pass "you opened 'man ls' — that's how you learn any command, offline and for real."
  else
    fail "run 'man ls' to open the manual (search with /reverse, quit with q), then check again"
    return 1
  fi
}
