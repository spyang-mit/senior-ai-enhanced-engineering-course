# shellcheck shell=bash disable=SC2034
TASK_TITLE="Validate at the boundary"
TASK_CAT="Validation & correct codes"
TASK_BODY="Now harden the server: reject bad input at the boundary with 400 + a
useful error message.

On your HOST machine, edit workspace/handlers/06-validate.py. This file defines
handle_create_order(). It currently accepts anything. Fix it to reject:
  • Missing items array → 400 'items is required'
  • qty <= 0 → 400 'qty must be a positive integer'
  • Unknown productId → 400 'unknown productId: N'

After editing, run lesson check. The server restarts and tests your validation."
TASK_TRY="Edit workspace/handlers/06-validate.py on your host"
TASK_WHY="Validation at the boundary is the server's first defense. If you accept
qty=0, the data store gets a meaningless order. If you accept unknown products,
the order references nothing real. Validate BEFORE you write to the store."
TASK_GOAL="Reject qty<=0, unknown productId, and missing items with 400 + error body"
TASK_HINTS=(
  "06-validate.py already has a stub — check the 'Current flaws' comment at the top."
  "The check function returns 400, {'error': '...'} — look at the existing tasks in 06-validate.py for the pattern."
  "After editing, run 'lesson check' from THIS container — it restarts the server and runs curl tests."
  "Test your edit first: curl -X POST ... -d '{\"items\":[{\"productId\":1,\"qty\":0}]}' should return 400."
)
needs_server() { true; }
setup() {
  link_handler "06-validate.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local base="http://localhost:8080/orders"
  local rc=0

  # Test 1: qty=0 → 400
  local out
  out=$(curl -s -o /dev/null -w '%{http_code}' -X POST $base $alice -d '{"items":[{"productId":1,"qty":0}]}' 2>/dev/null)
  if [ "$out" != "400" ]; then
    fail "qty=0 should return 400, got $out"; rc=1
  else
    pass "qty=0 → 400"
  fi

  # Test 2: unknown productId → 400
  out=$(curl -s -o /dev/null -w '%{http_code}' -X POST $base $alice -d '{"items":[{"productId":999,"qty":1}]}' 2>/dev/null)
  if [ "$out" != "400" ]; then
    fail "unknown productId should return 400, got $out"; rc=1
  else
    pass "unknown productId → 400"
  fi

  # Test 3: missing items → 400
  out=$(curl -s -o /dev/null -w '%{http_code}' -X POST $base $alice -d '{}' 2>/dev/null)
  if [ "$out" != "400" ]; then
    fail "missing items should return 400, got $out"; rc=1
  else
    pass "missing items → 400"
  fi

  # Test 4: valid input still works → 201
  out=$(curl -s -o /dev/null -w '%{http_code}' -X POST $base $alice -d '{"items":[{"productId":1,"qty":2}]}' 2>/dev/null)
  if [ "$out" != "201" ]; then
    fail "valid items should return 201, got $out"; rc=1
  else
    pass "valid items → 201"
  fi

  [ "$rc" -eq 0 ] && pass "validation at the boundary is working"
  return $rc
}
