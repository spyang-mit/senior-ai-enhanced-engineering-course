# shellcheck shell=bash disable=SC2034
TASK_TITLE="Capstone: build a refund endpoint"
TASK_CAT="Capstone"
TASK_BODY="Put it all together: own the contract, direct the build, verify it
hard. Design and build ONE new write path — POST /orders/{id}/refund.

1) Design it in the contract first (like tasks 3-4): add /orders/{id}/refund to
   ~/workspace/orders-api.yaml with bearer auth and its responses (200, 401,
   404, and a 409 if you like).
2) Implement it in ~/workspace/capstone/refund.py. Every senior habit from this
   module applies at once — the harness enforces them:
     • owner-only: a non-owner (or missing order) gets 404 (no leak)
     • server-authoritative: refund the order's OWN totalCents, never a
       client-supplied amount
     • idempotent: a retry with the same Idempotency-Key must not refund twice
     • honest codes: 200 on success, set status to \"refunded\"

Drive it with your AI from the contract if you like — then VERIFY. Run
'lesson check' to fire the full conformance battery at your handler."
TASK_TRY="less ~/workspace/capstone/refund.py"
TASK_WHY="This is the whole course thesis in one endpoint: you own the contract,
an agent can write the code, and you PROVE it's correct — including the hostile
cases (forged amount, someone else's order, a retry). That verification is the
senior deliverable, not the code itself."
TASK_HINTS=(
  "Look up the order (ctx.orders.get(req.order_id)); if it's missing OR not ctx.user's, return (404, {...})."
  "Idempotency: if req.header('Idempotency-Key') is set and already in ctx.idempotency, return the stored result; otherwise do the refund and store it."
  "The refund amount is order['totalCents'] (server-side), never anything from req.body. Set order['status']='refunded' and return (200, {'refundedCents': order['totalCents']})."
  "Give your AI the contract entry + these requirements and ask it to implement handle(req, ctx); then run lesson check to verify."
)
TASK_GOAL="Implement POST /orders/{id}/refund in ~/workspace/capstone/refund.py: owner-only, server-authoritative amount, idempotent, honest codes"
setup() { seed_contract; seed_capstone; }
check() {
  if run_harness refund "$CAPSTONE/refund.py"; then
    pass "refund is owner-only, priced by the server, idempotent, and honest about status codes — proven against good AND hostile requests. You own this endpoint end to end. 🎉"
  else
    fail "keep working on ~/workspace/capstone/refund.py until every check above is green, then run lesson check"
    return 1
  fi
}
