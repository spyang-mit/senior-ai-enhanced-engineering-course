# shellcheck shell=bash disable=SC2034
TASK_TITLE="Set permissions with octal"
TASK_CAT="Permissions"
TASK_BODY="The same permissions have a numeric shorthand. Add the values:
  r = 4   w = 2   x = 1
Sum them per class (owner, group, others) to get three digits:
  755 = rwxr-xr-x   (owner all; group & others read+execute)
  644 = rw-r--r--   (owner read/write; everyone else read)
  640 = rw-r-----   (owner read/write; group read; others nothing)
  600 = rw-------   (owner only)

secret.env holds credentials. Lock it down so ONLY the owner can read or
write it — nothing for group or others:"
TASK_TRY="chmod 600 ~/playground/secret.env"
TASK_WHY="ssh refuses to use a private key that isn't 600 for exactly this
reason. Octal is faster than symbolic once the numbers click — and they're
the same three rwx bits you already know."
TASK_HINTS=(
  "Owner read+write = 4+2 = 6; group and others = 0. So 600."
  "Run: chmod 600 ~/playground/secret.env"
)
check() {
  local f="$HOME/playground/secret.env"
  if mode_is "$f" 600; then
    pass "secret.env is now $(symbolic_mode_of "$f") (600) — owner-only."
  else
    fail "mode is $(mode_of "$f"); you want 600 (rw-------)"; return 1
  fi
}
