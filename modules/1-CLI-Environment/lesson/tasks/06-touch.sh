# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create empty files & update timestamps"
TASK_CAT="Files"
TASK_BODY="'touch' does one of two things, depending on whether the file
already exists:
  • NEW file       -> creates it, EMPTY: zero bytes, no contents
  • EXISTING file  -> leaves the contents alone, but sets its 'modified'
                      time to right now

First, make a new empty file and prove to yourself it's empty:
  touch scratch.txt
  ls -l scratch.txt      # look at the size column: 0 bytes
  cat scratch.txt        # prints nothing — there's nothing in it

Now watch touch bump a timestamp. There's an old file 'stale.txt' here:
  ls -l stale.txt        # note its old modified date (years ago)
  touch stale.txt        # touch it...
  ls -l stale.txt        # ...now its modified date is the current time"
TASK_TRY="touch scratch.txt        # then also: touch stale.txt"
TASK_WHY="Creating an empty file is how you start something from nothing. The
timestamp behavior matters more than it looks: build tools decide what to
rebuild by comparing file modified-times, so 'touch' is how you mark a file as
freshly changed. Seeing the 0-byte size and the changing date is the point."
TASK_HINTS=(
  "touch scratch.txt makes a new empty (0-byte) file — confirm with ls -l."
  "Then run: touch stale.txt   and compare 'ls -l stale.txt' before and after."
)
check() {
  local s="$HOME/playground/scratch.txt" old="$HOME/playground/stale.txt"
  if ! file_exists "$s"; then
    fail "make a new empty file: touch scratch.txt"; return 1
  fi
  if [ -s "$s" ]; then
    fail "scratch.txt should be EMPTY (0 bytes) — touch creates an empty file; you put content in it"; return 1
  fi
  # stale.txt started years old; if it was touched it will be very recent.
  if [ -f "$old" ] && [ -z "$(find "$old" -mmin +10 2>/dev/null)" ]; then
    pass "scratch.txt is a new 0-byte file, and you refreshed stale.txt's timestamp — both behaviors of touch."
  else
    fail "now run 'touch stale.txt' to update its old modified date to now (see it with: ls -l stale.txt)"; return 1
  fi
}
