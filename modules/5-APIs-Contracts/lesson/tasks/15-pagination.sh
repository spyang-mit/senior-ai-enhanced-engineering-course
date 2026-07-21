# shellcheck shell=bash disable=SC2034
TASK_TITLE="Paginate the list"
TASK_CAT="Scale & failure"
TASK_BODY="A list endpoint that returns EVERYTHING is a time bomb: fine with 3
orders, a disaster with 3 million. And the naive one returns everyone's orders,
not just yours:
  curl -s localhost:8080/orders -H 'Authorization: Bearer alice-token' | jq 'length'

Fix it in:
  ~/workspace/handlers/15-pagination.py
Per the contract, return only the caller's orders, honoring ?limit (default 20)
and ?offset (default 0), in the shape {\"total\": N, \"items\": [...]} where total
is the count of the caller's orders. Note req.query values are STRINGS — convert
them. Edit it, then run 'lesson check'."
TASK_TRY="less ~/workspace/handlers/15-pagination.py"
TASK_WHY="Pagination and per-user scoping are how a list endpoint stays fast and
private as data grows. 'Return the whole table' is one of the most common
performance and privacy bugs in AI-generated CRUD."
TASK_HINTS=(
  "Three steps in the TODO: filter to ctx.user's orders, slice by offset/limit, return {total, items}."
  "mine = [o for o in ctx.orders.values() if o['userId'] == ctx.user]; then int(req.query.get('limit',20)) and offset; return (200, {'total': len(mine), 'items': mine[offset:offset+limit]})."
)
TASK_GOAL="Return only the caller's orders as {total, items}, honoring limit/offset — edit ~/workspace/handlers/15-pagination.py"
setup() { seed_handler "15-pagination.py"; }
check() {
  if run_harness pagination "$HANDLERS/15-pagination.py"; then
    pass "the list is now scoped to the caller and paginated, with an honest total. It'll survive real data volumes."
  else
    fail "make ~/workspace/handlers/15-pagination.py filter + paginate + return {total, items} (see failing checks above), then run lesson check"
    return 1
  fi
}
