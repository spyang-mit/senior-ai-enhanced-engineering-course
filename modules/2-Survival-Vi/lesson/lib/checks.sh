# shellcheck shell=bash
# Assertions for the survival-vi lesson. Most tasks give you a file and a
# target; the check compares the file you saved against the expected content.
# These run inside the `lesson` process (a child of your shell), so they see
# the real files you edited in vi.

# --- basics -----------------------------------------------------------------

file_exists()  { [ -e "$1" ]; }
file_nonempty() { [ -s "$1" ]; }
file_contains() { [ -e "$1" ] && grep -qE -- "$2" "$1"; }
line_count()   { [ -e "$1" ] && wc -l < "$1" | tr -d ' '; }

# --- content comparison (the heart of vi checks) ----------------------------

# Normalize for comparison: strip trailing whitespace on each line, and drop
# any trailing blank lines (vim likes to add a final newline). Reads a file.
_norm() {
  sed 's/[[:space:]]*$//' "$1" | awk '
    { lines[NR] = $0 }
    END { n = NR; while (n > 0 && lines[n] == "") n--; for (i = 1; i <= n; i++) print lines[i] }
  '
}

# file_is <file>   — expected content is read from stdin.
# Passes when <file> matches the expected content after normalization.
file_is() {
  local f="$1"
  [ -f "$f" ] || return 1
  local tmp; tmp="$(mktemp)"
  cat > "$tmp"
  local rc=0
  diff <(_norm "$f") <(_norm "$tmp") >/dev/null 2>&1 || rc=1
  rm -f "$tmp"
  return $rc
}

# A compact diff (expected vs actual) to show a learner what's off, if anything.
show_diff() {
  local f="$1"
  local tmp; tmp="$(mktemp)"; cat > "$tmp"
  printf '%s\n' "${C_DIM}--- what differs (expected vs your file) ---${C_RESET}"
  diff --label expected --label yours -u <(_norm "$tmp") <(_norm "$f") 2>/dev/null \
    | sed -n '3,12p' | sed 's/^/  /'
  rm -f "$tmp"
}
