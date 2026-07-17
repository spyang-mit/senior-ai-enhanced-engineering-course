# shellcheck shell=bash disable=SC2034
TASK_TITLE="Get out alive (quit vi)"
TASK_CAT="Survival"
TASK_BODY="vi (and its modern version vim) is preinstalled on nearly every
Linux server in the world. It's awkward to use — but very often it's the ONLY
editor on a machine you've just logged into, so every seasoned Linux developer
knows how to get around it. You need to as well, and that's what this module is
for. We'll start with the single most useful skill: getting back OUT.

What makes vi awkward is MODES. When you open a file you're in NORMAL mode,
where letters are COMMANDS, not text — so typing does surprising things. To
type actual text you switch to INSERT mode by pressing 'i', and you press Esc
to switch back. Leaving vi is done from normal mode:
  press Esc            make sure you're in normal mode
  type  :q   + Enter   quit (works only if you changed nothing)
  type  :q!  + Enter   quit and THROW AWAY your changes

Your task: open haiku.txt in vim, make a change, then quit without saving it:
  vim haiku.txt
  1. press  i        to enter insert mode (you'll see -- INSERT -- at the bottom)
  2. type anything you like, to change the file
  3. press  Esc      to leave insert mode
  4. type  :q!  and Enter to quit WITHOUT saving
The file should be left exactly as it started."
TASK_TRY="vim haiku.txt"
TASK_WHY="Getting stuck in vi with no idea how to leave is a rite of passage —
and completely avoidable. ':q!' means you can always back out clean, no matter
what you (or some tool that dropped you into vi) did. Burn it into muscle
memory now."
TASK_HINTS=(
  "The order is: press i, type something, press Esc, then type :q! and press Enter."
  "If ':q' complains 'No write since last change', that's exactly what ':q!' overrides — the '!' discards your changes."
)
setup() {
  local f="$HOME/playground/haiku.txt"
  [ -e "$f" ] || printf 'an old silent pond\na frog jumps into the pond\nsplash! silence again\n' > "$f"
}
check() {
  local f="$HOME/playground/haiku.txt"
  [ -f "$f" ] || { fail "haiku.txt is missing — run 'lesson next' to get a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
an old silent pond
a frog jumps into the pond
splash! silence again
EOF
  then
    pass "haiku.txt is exactly as it started — you quit without saving. That's the skill that sets you free."
  else
    fail "the file changed, so you must have saved. Get a fresh copy (rm haiku.txt then lesson next), open it, mangle it, and leave with :q! — no save."
    return 1
  fi
}
