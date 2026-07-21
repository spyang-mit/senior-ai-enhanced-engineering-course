# shellcheck shell=bash disable=SC2034
TASK_TITLE="Make create idempotent via Idempotency-Key"
TASK_CAT="Idempotency (marquee)"
TASK_BODY="Now implement idempotent create. On your host, edit
workspace/handlers/10-idempotent.py.

The server should honor the Idempotency-Key header:
  • First POST with key X → creates the order, stores key→order_id
  • Second POST with same key X → returns the SAME order (200, not 201)
  • Different keys → different orders (as usual)

The handler function signature changed — it now receives idempotency_key as
a keyword argument. The reference server passes it from the header.

After editing, run lesson check. It tests idempotency by sending the same
key twice."
TASK_WHY="This is the marquee concept for Module 5. Idempotency-Key is how you
make POST idempotent: the client sends a unique key, and the server deduplicates.
Without it, retries cause double-orders — a real problem in every payment API."
TASK_GOAL="POST /orders with the same Idempotency-Key returns the same order twice"
TASK_HINTS=(
  "10-idempotent.py already has a stub — look for the _idem_store dict and the idempotency_key parameter."
  "The first request with a key creates the order and stores the mapping. The second with the same key looks up the stored order_id and returns that order."
  "The check sends: curl -s -X POST ... -H 'Idempotency-Key: abc123' — twice. Both should return the same order id."
)
needs_server() { true; }
setup() {
  link_handler "10-idempotent.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' -H 'Idempotency-Key: test-key-01'"
  local rc=0

  # First request — should create (201)
  local body1 order_id1
  body1=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  order_id1=$(echo "$body1" | jq -r '.id' 2>/dev/null)

  if [ -z "$order_id1" ] || [ "$order_id1" = "null" ]; then
    fail "first request didn't return an order id"; rc=1
  else
    pass "first request created order $order_id1"
  fi

  # Check status is 201
  local status1
  status1=$(curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  if [ "$status1" != "201" ]; then
    fail "first request should return 201, got $status1"; rc=1
  fi

  # Second request with SAME key — should return SAME order (200, not 201)
  local body2 order_id2
  body2=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  order_id2=$(echo "$body2" | jq -r '.id' 2>/dev/null)

  if [ "$order_id2" != "$order_id1" ]; then
    fail "second request with same key returned a DIFFERENT order ($order_id2 vs $order_id1)"; rc=1
  else
    pass "second request returned the same order $order_id1 (idempotent)"
  fi

  # Check status is 200 (not 201 — it's a replay)
  local status2
  status2=$(curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  if [ "$status2" != "200" ]; then
    fail "second request should return 200 (replay), got $status2"; rc=1
  else
    pass "second request → 200 (replay, not new create)"
  fi

  [ "$rc" -eq 0 ] && pass "idempotent create is working"
  return $rc
}
