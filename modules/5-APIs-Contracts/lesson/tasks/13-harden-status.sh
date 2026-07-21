# shellcheck shell=bash disable=SC2034
TASK_TITLE="Harden: server-authoritative status"
TASK_CAT="Never trust the client (core)"
TASK_BODY="Another trust-boundary violation: the client can set the order status.
Try creating an order with status='paid':
  curl -s -X POST http://localhost:8080/orders \\
    -H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' \\
    -d '{"items":[{"productId":1,"qty":1}], "status":"paid"}'

The naive server stores 'paid' — but the server should OWN the status lifecycle.
An order starts as 'pending' and transitions ONLY by server action (cancel, refund).

Edit workspace/handlers/13-status.py to:
  1. ALWAYS set status to 'pending' on create (ignore client status)
  2. Make cancel server-authoritative: only 'pending' → 'cancelled', not flip-flop
  3. Make cancel idempotent: cancelling twice stays 'cancelled'

Then run lesson check."
TASK_WHY="Status is a server-authoritative field. If the client sets it, they can
skip payment, skip shipping, or set impossible states. The server controls the
state machine — the client only sends commands (cancel, refund), not status values."
TASK_GOAL="Server sets status on create; cancel is idempotent with correct transitions"
TASK_HINTS=(
  "13-status.py has a stub — in handle_create_order, always set status='pending' regardless of what the client sends."
  "For handle_cancel_order: if status is 'pending', change to 'cancelled'. If already 'cancelled', return 200 without changing. If neither, return 409."
)
needs_server() { true; }
setup() {
  link_handler "13-status.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local rc=0

  # Test 1: client sends status='paid' → server ignores, stores 'pending'
  local body1
  body1=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}],"status":"paid"}' 2>/dev/null)
  local status1 oid
  status1=$(echo "$body1" | jq -r '.status' 2>/dev/null)
  oid=$(echo "$body1" | jq -r '.id' 2>/dev/null)

  if [ "$status1" != "pending" ]; then
    fail "client-set status='paid' should be ignored, server stored '$status1'"; rc=1
  else
    pass "client status ignored — server set '$status1'"
  fi

  # Test 2: cancel once → cancelled
  local status2
  status2=$(curl -s -X POST "http://localhost:8080/orders/$oid/cancel" $alice -d '{}' | jq -r '.status' 2>/dev/null)
  if [ "$status2" != "cancelled" ]; then
    fail "cancel should set status to 'cancelled', got '$status2'"; rc=1
  else
    pass "cancel → '$status2'"
  fi

  # Test 3: cancel again → still cancelled (idempotent)
  local status3
  status3=$(curl -s -X POST "http://localhost:8080/orders/$oid/cancel" $alice -d '{}' | jq -r '.status' 2>/dev/null)
  if [ "$status3" != "cancelled" ]; then
    fail "second cancel changed status to '$status3' — should stay cancelled"; rc=1
  else
    pass "second cancel — still '$status3' (idempotent)"
  fi

  [ "$rc" -eq 0 ] && pass "server-authoritative status is working"
  return $rc
}
