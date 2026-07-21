# shellcheck shell=bash
# Assertions for the APIs & contracts lesson.
# The orders API runs at $API inside the sandbox.
# Checks restart the server, curl endpoints, read the access log, and validate
# YAML contract files in the mounted workspace.

API="http://localhost:8080"
ACCESS_LOG="$HOME/.server/access.log"
SERVER_PID_FILE="$HOME/.server/server.pid"
WORKSPACE="/home/dev/workspace"
HANDLER_DIR="$WORKSPACE/handlers"

# --- files ------------------------------------------------------------------
file_exists()   { [ -e "$1" ]; }
file_nonempty() { [ -s "$1" ]; }
file_contains() { [ -e "$1" ] && grep -qiE -- "$2" "$1"; }

# --- server lifecycle -------------------------------------------------------

# Restart the server so it re-imports handler files from the workspace.
# Called by lesson check BEFORE the task's check() runs.
restart_server() {
  # Kill old server if running
  local old_pid
  if [ -f "$SERVER_PID_FILE" ]; then
    old_pid=$(cat "$SERVER_PID_FILE" 2>/dev/null || echo "")
    [ -n "$old_pid" ] && kill "$old_pid" 2>/dev/null || true
  fi
  # Also kill any python3 process running the reference server
  pkill -f "reference-server.py" 2>/dev/null || true
  sleep 0.3

  # Clear access log
  : > "$ACCESS_LOG" 2>/dev/null || true

  # Start fresh
  local out="$HOME/.server/server.out"
  ACCESS_LOG="$ACCESS_LOG" setsid python3 /opt/server/reference-server.py > "$out" 2>&1 < /dev/null &
  local pid=$!
  echo "$pid" > "$SERVER_PID_FILE"
  sleep 0.5

  # Verify it started
  if ! curl -s -o /dev/null -w '%{http_code}' "$API/products" 2>/dev/null | grep -qE '^2'; then
    echo "${C_RED}✗ Server failed to start. Check the handler file for syntax errors:${C_RESET}"
    cat "$out" 2>/dev/null
    return 1
  fi
  return 0
}

# --- the API ----------------------------------------------------------------

api_up() { curl -s -o /dev/null -w '%{http_code}' "$API/products" 2>/dev/null | grep -qE '^2'; }

# --- the access log ---------------------------------------------------------

clear_access_log() { : > "$ACCESS_LOG" 2>/dev/null || true; }
log_has() { [ -r "$ACCESS_LOG" ] && grep -qE -- "$1" "$ACCESS_LOG"; }

# --- YAML contract validation -----------------------------------------------

# Validate that a YAML file exists and contains a given string (simple grep).
yaml_has() {
  local f="$WORKSPACE/$1"; shift
  [ -f "$f" ] || return 1
  for pattern; do
    grep -qE -- "$pattern" "$f" || return 1
  done
  return 0
}

# --- handler symlink management ---------------------------------------------

# Symlink a handler file as the active handler. The server loads active.py.
link_handler() {
  local src="$1"  # relative to HANDLER_DIR, e.g. "06-validate.py"
  ln -sf "$HANDLER_DIR/$src" "$HANDLER_DIR/active.py"
}

# --- behavioral battery helpers ---------------------------------------------

# Run a curl test: assert status code and optional body content.
# Usage: test_curl <method> <url> <expected_status> [expected_body_substring]
test_curl() {
  local method="$1" url="$2" expect="$3" want_body="$4"
  local out rc=0
  out=$(curl -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null) || rc=1
  if [ "$out" != "$expect" ]; then
    fail "expected status $expect, got $out for $method $url"
    return 1
  fi
  if [ -n "$want_body" ]; then
    local body
    body=$(curl -s "$url" 2>/dev/null)
    if ! echo "$body" | grep -qE "$want_body"; then
      fail "response body doesn't contain '$want_body'"
      return 1
    fi
  fi
  pass "$method $url → $expect"
  return 0
}
