# shellcheck shell=bash
# Shared check helpers for Module 5. Sourced by run.sh (which also sources ui.sh).

API="http://localhost:8080"
TOKEN_ALICE="alice-token"
TOKEN_BOB="bob-token"
WORKSPACE="$HOME/workspace"
HANDLERS="$WORKSPACE/handlers"
CAPSTONE="$WORKSPACE/capstone"
SEED_DIR="/opt/lesson/handlers-seed"
CONTRACT="$WORKSPACE/orders-api.yaml"

# --- files -----------------------------------------------------------------
file_exists()   { [ -f "$1" ]; }
file_nonempty() { [ -s "$1" ]; }
file_contains() { [ -f "$1" ] && grep -qiE "$2" "$1"; }

# --- the live naive server -------------------------------------------------
api_up() { curl -s -o /dev/null "$API/products" 2>/dev/null; }

# --- seeding (backstops; entrypoint seeds at container start) ---------------
# Copy a starter file into the workspace only if it's missing, so we never
# clobber the learner's edits.
seed_handler()  { mkdir -p "$HANDLERS";  [ -f "$HANDLERS/$1" ]  || cp "$SEED_DIR/$1" "$HANDLERS/$1" 2>/dev/null || true; }
seed_contract() { mkdir -p "$WORKSPACE"; [ -f "$CONTRACT" ]     || cp /opt/app/orders-api.yaml "$CONTRACT" 2>/dev/null || true; }
seed_capstone() { mkdir -p "$CAPSTONE"; [ -f "$CAPSTONE/refund.py" ] || cp "$SEED_DIR/capstone-refund.py" "$CAPSTONE/refund.py" 2>/dev/null || true; }

# --- the behavioral harness ------------------------------------------------
# run_harness <drill> <handler-file> : prints the per-check ✓/✗ lines, returns
# 0 only if every assertion passed. Exit 3 (won't import) is treated as failure.
run_harness() {
  local drill="$1" f="$2"
  if [ ! -f "$f" ]; then
    fail "handler file not found: $f  (run 'lesson next' to reseed the starter)"
    return 1
  fi
  python3 /opt/lesson/lib/harness.py "$drill" "$f"
}

# --- contract (YAML) assertions --------------------------------------------
# Parse the learner's orders-api.yaml with PyYAML and assert structure.
_contract_py() { python3 -c "$1" "$CONTRACT" 2>/dev/null; }

contract_valid() {
  _contract_py 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))'
}
contract_has_409_on_post_orders() {
  _contract_py '
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
r = d["paths"]["/orders"]["post"]["responses"]
sys.exit(0 if ("409" in r or 409 in r) else 1)
'
}
contract_has_cancel_path() {
  _contract_py '
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
p = d.get("paths", {})
path = p.get("/orders/{id}/cancel")
if not path or "post" not in path:
    sys.exit(1)
resp = path["post"].get("responses", {})
ok = any(str(c).startswith("2") for c in resp)   # at least one 2xx
sys.exit(0 if ok else 1)
'
}
