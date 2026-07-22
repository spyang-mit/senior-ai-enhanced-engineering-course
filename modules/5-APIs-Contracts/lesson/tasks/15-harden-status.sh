# shellcheck shell=bash disable=SC2034
TASK_TITLE="Harden: server owns the status"
TASK_CAT="Never trust the client"
TASK_BODY="Same class of bug, higher stakes. Watch a client create an order that's
already 'paid' — without paying:
  curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' \\
    -d '{\"items\":[{\"productId\":1,\"qty\":1}],\"status\":\"paid\"}' | jq '{status}'

The status lifecycle (pending -> paid -> shipped) is the server's to control, via
real events (a payment succeeding), never the create payload. Fix it in:
  ~/workspace/handlers/status.py
A new order is ALWAYS 'pending'; ignore any client-sent status. Then run
'lesson check'."
TASK_TRY="curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{\"items\":[{\"productId\":1,\"qty\":1}],\"status\":\"paid\"}' | jq '{status}'"
TASK_WHY="State transitions are authority. If the client can set status, it can
skip payment, un-cancel, or re-ship at will. The server must drive the lifecycle
from events it trusts — the create just starts it at 'pending'."
TASK_HINTS=(
  "The naive line reads status from req.body. A brand-new order should never take its status from the client."
  "Set status to the literal \"pending\" when creating; ignore req.body's status entirely."
)
TASK_GOAL="Force new orders to status 'pending', ignoring the client — edit ~/workspace/handlers/status.py"
setup() { seed_handler "status.py"; }
check() {
  if run_harness status "$HANDLERS/status.py"; then
    pass "a client-sent 'paid' is ignored — new orders start 'pending'. The lifecycle belongs to the server."
  else
    fail "make ~/workspace/handlers/status.py force status to 'pending' (see failing check above), then run lesson check"
    return 1
  fi
}
