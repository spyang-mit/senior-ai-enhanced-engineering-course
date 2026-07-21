# shellcheck shell=bash disable=SC2034
TASK_TITLE="Pagination: ?limit and ?offset"
TASK_CAT="Scale & failure semantics"
TASK_BODY="The current server returns ALL orders with no pagination. For a real
API, that doesn't scale. Add pagination support to GET /orders.

Edit workspace/handlers/15-pagination.py. handle_paginated_orders should:
  • Read ?limit=N (default 20, min 1) and ?offset=M (default 0, min 0)
  • Return a paginated envelope: { "items": [...], "total": <count> }
  • Respect the page size (don't return more than limit items)
  • Include total so the client can render pagination controls

This handler also includes all previous hardening (validation, idempotency,
server-authoritative pricing and status, authorization) — it's the cumulative
handler before the capstone.

Then run lesson check."
TASK_WHY="Without pagination, a client fetching 10k orders gets a huge response
(and the server does a huge scan). Pagination is a contract concern: the contract
says ?limit and ?offset exist, and the server must honor them. The response
envelope with 'total' lets the client render page controls."
TASK_GOAL="GET /orders?limit=5&offset=0 returns at most 5 items with a total count"
TASK_HINTS=(
  "15-pagination.py has a stub — look for handle_paginated_orders. Read query params from the query dict."
  "The envelope format: { 'items': [...], 'total': N } — not just a bare array."
  "The check creates 10+ orders as Alice, then fetches with limit=3 and checks the response shape."
)
needs_server() { true; }
setup() {
  link_handler "15-pagination.py"
  clear_access_log
}
check() {
  local alice="-H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json'"
  local rc=0

  # Seed some orders so pagination matters
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -s -X POST http://localhost:8080/orders $alice -d '{"items":[{"productId":1,"qty":1}]}' >/dev/null 2>&1
  done

  # Fetch with limit=3
  local body
  body=$(curl -s "http://localhost:8080/orders?limit=3&offset=0" $alice 2>/dev/null)

  # Check envelope shape
  local has_items has_total
  has_items=$(echo "$body" | jq -r 'has("items")' 2>/dev/null)
  has_total=$(echo "$body" | jq -r 'has("total")' 2>/dev/null)

  if [ "$has_items" != "true" ] || [ "$has_total" != "true" ]; then
    fail "response should have {items, total} envelope — got: $(echo "$body" | head -c 200)"; rc=1
  else
    pass "response has paginated envelope (items + total)"
  fi

  # Check page size honored
  local page_size
  page_size=$(echo "$body" | jq -r '.items | length' 2>/dev/null)
  if [ "$page_size" -gt 3 ]; then
    fail "limit=3 returned $page_size items — page size not honored"; rc=1
  else
    pass "limit=3 → $page_size items"
  fi

  # Check total is correct
  local total
  total=$(echo "$body" | jq -r '.total' 2>/dev/null)
  if [ "$total" -lt 10 ]; then
    fail "total=$total — should be >= 10 (we seeded 10 orders)"; rc=1
  else
    pass "total=$total"
  fi

  [ "$rc" -eq 0 ] && pass "pagination is working"
  return $rc
}
