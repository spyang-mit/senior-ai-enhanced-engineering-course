# shellcheck shell=bash disable=SC2034
TASK_TITLE="Authorization: owner-only orders"
TASK_CAT="Never trust the client (core)"
TASK_BODY="The biggest trust-boundary violation: Alice can read Bob's orders.

Prove it first:
  1. As Alice, create an order:     curl -s -X POST ... -H 'Authorization: Bearer alice-token' ...
  2. As Bob, read Alice's order:    curl -s .../orders/{id} -H 'Authorization: Bearer bob-token'

The naive server returns Alice's order to Bob — no owner check.

Now edit workspace/handlers/14-auth.py to add owner-only checks:
  • GET /orders → filter to only the authenticated user's orders
  • GET /orders/{id} → return 403 if the order belongs to another user
  • POST /orders/{id}/cancel → return 403 if the order belongs to another user
  • Distinguish 401 (no auth) vs 403 (auth but forbidden)

Also fix the 401 vs 403 distinction:
  • No token → 401 'missing or invalid bearer token'
  • Valid token but wrong user → 403 'forbidden: this order belongs to another user'
  • Order doesn't exist → 404 'order not found' (even for valid tokens)

Then run lesson check."
TASK_WHY="Authentication (who is this?) vs authorization (may they do this?) is the
most misunderstood distinction in HTTP APIs. 401 = no valid credentials. 403 =
credentials valid but insufficient permission. Getting it wrong means Alice
knows Bob's order ids — a privacy leak."
TASK_GOAL="Alice cannot read Bob's orders; 401 vs 403 is correct"
TASK_HINTS=(
  "14-auth.py has a stub — add userId checks to handle_get_order, handle_cancel_order, and handle_get_orders."
  "For handle_get_order: if order.userId != user, return 403. If order is None, return 404."
  "For handle_get_orders: filter the list to only orders where order.userId == user."
  "The check tests: Alice creates → Bob reads (403), Bob lists (no Alice orders), Alice reads own (200)."
)
needs_server() { true; }
setup() {
  link_handler "14-auth.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local bob="-H 'Authorization: Bearer bob-token' -H 'Content-Type: application/json'"
  local rc=0

  # Alice creates an order
  local body alice_order_id
  body=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' 2>/dev/null)
  alice_order_id=$(echo "$body" | jq -r '.id' 2>/dev/null)

  if [ -z "$alice_order_id" ] || [ "$alice_order_id" = "null" ]; then
    fail "Alice couldn't create an order"; rc=1
  else
    pass "Alice created order $alice_order_id"
  fi

  # Bob tries to read Alice's order → 403
  local bob_status
  bob_status=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/orders/$alice_order_id" $bob 2>/dev/null)
  if [ "$bob_status" != "403" ]; then
    fail "Bob reading Alice's order should return 403, got $bob_status"; rc=1
  else
    pass "Bob → 403 on Alice's order"
  fi

  # Bob tries to cancel Alice's order → 403
  local bob_cancel_status
  bob_cancel_status=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://localhost:8080/orders/$alice_order_id/cancel" $bob 2>/dev/null)
  if [ "$bob_cancel_status" != "403" ]; then
    fail "Bob cancelling Alice's order should return 403, got $bob_cancel_status"; rc=1
  else
    pass "Bob → 403 on cancel"
  fi

  # Alice reads her own order → 200
  local alice_status
  alice_status=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/orders/$alice_order_id" $alice 2>/dev/null)
  if [ "$alice_status" != "200" ]; then
    fail "Alice reading her own order should return 200, got $alice_status"; rc=1
  else
    pass "Alice → 200 on own order"
  fi

  # Bob lists orders — should see 0 Alice orders
  local bob_list
  bob_list=$(curl -s "http://localhost:8080/orders" $bob 2>/dev/null)
  local bob_count
  bob_count=$(echo "$bob_list" | jq -r 'length' 2>/dev/null)
  # Bob might have his own orders, but shouldn't see Alice's
  local bob_has_alice
  bob_has_alice=$(echo "$bob_list" | jq -r '.[] | select(.userId=="Alice") | .id' 2>/dev/null)
  if [ -n "$bob_has_alice" ]; then
    fail "Bob's order list contains Alice's orders — owner filter broken"; rc=1
  else
    pass "Bob's order list doesn't contain Alice's orders"
  fi

  [ "$rc" -eq 0 ] && pass "authorization is working"
  return $rc
}
