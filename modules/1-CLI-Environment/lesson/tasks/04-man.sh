# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the manual (man)"
TASK_CAT="Getting help"
TASK_BODY="Every command comes with a manual. 'man' opens it:
  man ls          the manual for ls
  man man         the manual about man itself
  ls --help       a shorter summary many commands also offer

The manual opens in a pager. Navigation keys (worth memorizing — they also
work in 'less' and 'git log'):
  Space / b        page down / page up
  Ctrl-f / Ctrl-b  forward / back a screen (f=forward, b=back)
  /word  then n    search for 'word', jump to next match
  q                quit back to your shell

Use 'man ls' to find the flag that REVERSES the listing order, then save it:"
TASK_TRY="man ls        # then type /reverse and Enter to search; q to quit"
TASK_WHY="The manual is the offline, always-correct source of truth — reach
for it before guessing or googling. (These pager keys are a gentle preview of
vi-style navigation; Module 2 teaches survival vi for writing git commit
messages.)"
TASK_HINTS=(
  "Inside 'man ls', type  /reverse  then Enter. You'll land on the -r flag. Press q to quit."
  "Save the flag: echo '-r' > ~/playground/man-answer.txt"
)
check() {
  local f="$HOME/playground/man-answer.txt"
  if [ -e "$f" ] && grep -Eiq -- '(-r\b|reverse)' "$f"; then
    pass "you found -r in the manual and saved it — that's how you learn any command."
  else
    fail "use 'man ls', find the reverse-order flag (-r), and save it to ~/playground/man-answer.txt"
    return 1
  fi
}
