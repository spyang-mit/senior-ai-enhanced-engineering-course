# shellcheck shell=bash disable=SC2034
TASK_TITLE="Authorization: owner-only"
TASK_CAT="Never trust the client"
TASK_BODY="Authentication asks 'who are you?'; AUTHORIZATION asks 'may you?'. The
naive server authenticates (it checks the token) but never authorizes — so Alice
can read Bob's order:
  curl -s localhost:8080/orders/2 -H 'Authorization: Bearer alice-token' | jq '{id,userId}'
Order 2 is Bob's, yet Alice gets it. A classic broken-access-control leak.

Fix it in:
  ~/workspace/handlers/auth.py
Only the owner may read an order. If it isn't the caller's, return 404 (don't
even confirm it exists). Note the code choices: 401 = no/invalid token,
403 = valid token but not allowed, 404 = we won't reveal it exists. We use 404
here. Edit it, then run 'lesson check'."
TASK_TRY="curl -s localhost:8080/orders/2 -H 'Authorization: Bearer alice-token' | jq '{id,userId}'"
TASK_WHY="Authentication without authorization is the most common serious API
vulnerability there is. 'You're logged in' never means 'you may touch THIS.'
Every resource read/write must check ownership on the server."
TASK_HINTS=(
  "The order dict has a 'userId'. Compare it to ctx.user (the authenticated caller)."
  "If order['userId'] != ctx.user, return (404, {\"error\": \"not found\"}) — same as if it didn't exist."
  "Ask your AI: 'only the owner may read this order; otherwise 404 so we don't leak that it exists.'"
)
TASK_GOAL="Return 404 when the caller isn't the order's owner — edit ~/workspace/handlers/auth.py"
setup() { seed_handler "auth.py"; }
check() {
  if run_harness auth "$HANDLERS/auth.py"; then
    pass "owners read their own orders; everyone else gets 404. Authentication AND authorization — the trust boundary is closed."
  else
    fail "add the ownership check to ~/workspace/handlers/auth.py (see failing checks above), then run lesson check"
    return 1
  fi
}
