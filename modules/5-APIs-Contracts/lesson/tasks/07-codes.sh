# shellcheck shell=bash disable=SC2034
TASK_TITLE="Right codes: 201 for create, 404 for missing"
TASK_CAT="Validation & correct codes"
TASK_BODY="The current server has wrong status codes in two places:
  • POST /orders returns 200 on success — it should return 201 Created
  • GET /orders/{id} for a missing order returns 200 with null — should be 404

On your host, edit workspace/handlers/07-codes.py:
  1. handle_create_order should return 201, not 200
  2. handle_get_order should return 404 when the order doesn't exist

Then run lesson check."
TASK_WHY="Status codes are part of the contract. Returning 200 instead of 201
means the client can't distinguish 'new thing created' from 'here is the thing.'
Returning 200 for a missing resource hides errors — the client thinks it got data."
TASK_GOAL="POST → 201 on success, GET /orders/{id} → 404 if missing"
TASK_HINTS=(
  "07-codes.py has a stub — look for 'return 200, order' in handle_create_order and change it to 201."
  "In handle_get_order, add a None check before the return — if order is None, return 404."
  "After editing, run 'lesson check' — it restarts the server and tests both cases."
)
needs_server() { true; }
setup() {
  link_handler "07-codes.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local rc=0

  # Test 1: create → 201
  local out
  out=$(curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  if [ "$out" != "201" ]; then
    fail "create should return 201, got $out"; rc=1
  else
    pass "create → 201"
  fi

  # Get the order id from the response for the next test
  local body order_id
  body=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":2,"qty":1}]}' 2>/dev/null)
  order_id=$(echo "$body" | jq -r '.id' 2>/dev/null)

  # Test 2: get existing order → 200
  out=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/orders/$order_id" $alice 2>/dev/null)
  if [ "$out" != "200" ]; then
    fail "get existing order should return 200, got $out"; rc=1
  else
    pass "get existing order → 200"
  fi

  # Test 3: get missing order → 404
  out=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/orders/99999" $alice 2>/dev/null)
  if [ "$out" != "404" ]; then
    fail "get missing order should return 404, got $out"; rc=1
  else
    pass "get missing order → 404"
  fi

  [ "$rc" -eq 0 ] && pass "status codes are correct"
  return $rc
}
