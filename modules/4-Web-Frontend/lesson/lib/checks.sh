# shellcheck shell=bash
# Assertions for the web/frontend lesson. The contacts API runs at $API inside
# the sandbox; checks curl it, inspect saved answer files, or read the server's
# access log (to confirm which endpoints a frontend actually hit).

API="http://localhost:8080"
ACCESS_LOG="$HOME/.server/access.log"

# --- files ------------------------------------------------------------------

file_exists()   { [ -e "$1" ]; }
file_nonempty() { [ -s "$1" ]; }
file_contains() { [ -e "$1" ] && grep -qiE -- "$2" "$1"; }
digits_in()     { tr -dc '0-9' < "$1" 2>/dev/null; }   # first run of digits-ish

# Normalized content compare (expected on stdin) — used for a few answer files.
_norm() { sed 's/[[:space:]]*$//' "$1" | awk '{l[NR]=$0} END{n=NR; while(n>0&&l[n]=="")n--; for(i=1;i<=n;i++)print l[i]}'; }
file_is() {
  local f="$1"; [ -f "$f" ] || return 1
  local t; t="$(mktemp)"; cat > "$t"
  local rc=0; diff <(_norm "$f") <(_norm "$t") >/dev/null 2>&1 || rc=1
  rm -f "$t"; return $rc
}

# --- the API ----------------------------------------------------------------

api_up() { [ "$(curl -s -o /dev/null -w '%{http_code}' "$API/contacts" 2>/dev/null)" = "200" ]; }

# --- the access log ---------------------------------------------------------

clear_access_log() { : > "$ACCESS_LOG" 2>/dev/null || true; }

# Did a request matching this extended-regex appear in the access log?
# e.g. log_has '^POST /contacts '   or   log_has '^PUT /contacts/[0-9]+ '
log_has() { [ -r "$ACCESS_LOG" ] && grep -qE -- "$1" "$ACCESS_LOG"; }
