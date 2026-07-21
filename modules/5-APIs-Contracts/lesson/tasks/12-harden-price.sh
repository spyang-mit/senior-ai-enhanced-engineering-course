# shellcheck shell=bash disable=SC2034
TASK_TITLE="Harden: server computes the total"
TASK_CAT="Never trust the client (core)"
TASK_BODY="Now fix the exploit. Edit workspace/handlers/12-hardened.py so that
handle_create_order ALWAYS computes totalCents from the catalog × quantities,
ignoring any totalCents in the request body.

The server must:
  • Ignore client-provided totalCents
  • Compute total = sum(product.priceCents × qty) for each item
  • Store the computed total in the order

Also keep idempotency-key support from the previous task.

Then run lesson check."
TASK_WHY="Never trust the client: the server is the authority on prices. If the
client can set the price, they can pay anything. This is the most important
hardening in the module — it's the pattern for every server-authoritative field."
TASK_GOAL="Server computes totalCents from the catalog, ignores client totalCents"
TASK_HINTS=(
  "12-hardened.py has a stub — look for where total is computed. The fix is to compute it from PRODUCT_BY_ID and never read data.get('totalCents')."
  "The check sends two requests: one with a forged totalCents (should be ignored) and one without. Both should have the correct catalog total."
)
needs_server() { true; }
setup() {
  link_handler "12-hardened.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local rc=0

  # Test 1: forged totalCents should be ignored
  local body1
  body1=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":2}],"totalCents":1}' 2>/dev/null)
  local total1
  total1=$(echo "$body1" | jq -r '.totalCents' 2>/dev/null)

  if [ "$total1" != "5998" ]; then
    fail "forged totalCents:1 should be ignored, got totalCents=$total1 (expected 5998 = 2× Widget)"; rc=1
  else
    pass "forged totalCents:1 ignored — server computed $total1"
  fi

  # Test 2: no totalCents sent — server computes correctly
  local body2
  body2=$(curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1},{"productId":3,"qty":3}]}' 2>/dev/null)
  local total2
  total2=$(echo "$body2" | jq -r '.totalCents' 2>/dev/null)

  if [ "$total2" != "5996" ]; then
    fail "multi-item order: expected 5996 (Widget + 3× Doohickey), got totalCents=$total2"; rc=1
  else
    pass "multi-item order total=$total2"
  fi

  [ "$rc" -eq 0 ] && pass "server-authoritative pricing is working"
  return $rc
}
