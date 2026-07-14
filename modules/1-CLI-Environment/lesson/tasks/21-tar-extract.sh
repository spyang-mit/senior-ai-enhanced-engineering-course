# shellcheck shell=bash disable=SC2034
TASK_TITLE="Extract an archive"
TASK_CAT="Moving bytes: tar"
TASK_BODY="'x' extracts. Someone left you a compressed archive of old logs at
archive/oldlogs.tar.gz. Unpack it — but into a NEW directory so it doesn't
scatter files into your current one:
  mkdir -p restored
  tar xzf archive/oldlogs.tar.gz -C restored

  x = extract   z = gunzip   f = file    -C = change to this dir first"
TASK_TRY="mkdir -p restored && tar xzf archive/oldlogs.tar.gz -C restored"
TASK_WHY="Extracting straight into your working directory is how people end up
with 40 stray files everywhere. '-C targetdir' keeps every extraction tidy
and contained."
TASK_HINTS=(
  "Make the target dir, then extract with x z f and -C into it."
  "Run the full command shown under 'Try:'."
)
check() {
  local d="$HOME/playground/restored"
  if [ -d "$d" ] && [ -n "$(find "$d" -type f 2>/dev/null | head -1)" ]; then
    pass "extracted the old logs into restored/ — files are there."
  else
    fail "expected extracted files under restored/"; return 1
  fi
}
