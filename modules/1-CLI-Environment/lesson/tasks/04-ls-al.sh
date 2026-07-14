# shellcheck shell=bash disable=SC2034
TASK_TITLE="See everything, in detail"
TASK_CAT="Navigation"
TASK_BODY="'ls' lists a directory. The flags matter:
  ls        names only
  ls -a     include hidden entries (those starting with a dot, like .env)
  ls -l     long format: permissions, owner, group, size, date, name
  ls -al    both — the combination you'll type most

Save a detailed listing so we can dissect it. Capture it to a file, then
open that file to read it back:
  ls -al > listing.txt      # write the listing into a file
  cat listing.txt           # dump it to the screen
  less listing.txt          # or page through it (arrows/Space; q to quit)
                            # 'more listing.txt' works too"
TASK_TRY="ls -al > listing.txt   ;   cat listing.txt"
TASK_WHY="That '>' sends the output into a file instead of the screen (more
on that next); 'cat'/'less'/'more' read it back. The README breaks down every
column of an 'ls -al' line — read it; those columns are how you diagnose
permission bugs."
TASK_HINTS=(
  "Combine the flags: ls -al, redirect with >, then view with cat or less."
  "Run: ls -al > listing.txt   then   cat listing.txt"
)
check() {
  local f="$HOME/playground/listing.txt"
  if file_nonempty "$f" && file_contains "$f" "^total "; then
    pass "captured a long listing to listing.txt"
  else
    fail "no 'ls -al' output found in listing.txt yet"
    return 1
  fi
}
