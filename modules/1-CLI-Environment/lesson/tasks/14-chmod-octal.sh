# shellcheck shell=bash disable=SC2034
TASK_TITLE="Set permissions with octal"
TASK_CAT="Permissions"
TASK_BODY="Instead of nudging one bit at a time with +/-, you can set ALL the
permissions at once with a number. Each permission has a value:
  r = 4    w = 2    x = 1
Add them up within each class (owner, group, others) to get one digit each —
three digits in all:
  7 = 4+2+1 = rwx     5 = 4+0+1 = r-x     6 = 4+2+0 = rw-     0 = ---

Then apply all three digits in ONE command with 'chmod <number> file':
  chmod 755 file   ->  rwxr-xr-x   (owner rwx; group & others r-x)
  chmod 644 file   ->  rw-r--r--   (owner rw-; everyone else r--)
  chmod 640 file   ->  rw-r-----   (owner rw-; group r--; others nothing)
  chmod 600 file   ->  rw-------   (owner only)

Unlike 'chmod g+w' (which flips a single bit), 'chmod 755' REPLACES the whole
set of nine bits in one shot — no +/- needed.

Your task: secret.env holds credentials. Lock it down so ONLY the owner can
read or write it — nothing for the group, nothing for others. Work out the
three-digit number and set it with a single chmod."
TASK_TRY=""
TASK_WHY="ssh refuses to use a private key that isn't 600 for exactly this
reason. Octal is faster than symbolic once the numbers click — it's the same
rwx bits you already know, just added up."
TASK_HINTS=(
  "Run: chmod 600 secret.env"
)
check() {
  local f="$HOME/playground/secret.env"
  if mode_is "$f" 600; then
    pass "secret.env is now $(symbolic_mode_of "$f") (600) — owner-only."
  else
    fail "mode is $(mode_of "$f"); you want 600 (rw-------)"; return 1
  fi
}
