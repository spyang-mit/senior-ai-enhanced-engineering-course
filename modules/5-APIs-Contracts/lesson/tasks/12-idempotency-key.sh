# shellcheck shell=bash disable=SC2034
TASK_TITLE="Make create idempotent"
TASK_CAT="Idempotency"
TASK_BODY="You can make even a create safe to retry: let the client send an
Idempotency-Key, and have the server return the SAME order when it sees that key
again — instead of making a second one.

The naive server ignores the header (try it: two POSTs with the same
Idempotency-Key still make two orders). Implement it properly in:
  ~/workspace/handlers/idempotent.py
Use ctx.idempotency (a dict) to remember key -> order: on a repeat key, return
the stored order; otherwise create it and store it. Edit on your host, then run
'lesson check' — it retries with the same key and a different key."
TASK_TRY="curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -H 'Idempotency-Key: k1' -d '{\"items\":[{\"productId\":1,\"qty\":1}]}'"
TASK_WHY="This is the pattern real payment and order APIs use (Stripe's is exactly
this). It's the piece that makes 'retry on timeout' correct rather than
dangerous — the direct payoff of the last two tasks."
TASK_HINTS=(
  "Two TODOs in ~/workspace/handlers/idempotent.py: check the key on the way in, store it on the way out."
  "If key and key in ctx.idempotency: return (200, ctx.idempotency[key]). Otherwise create, then if key: ctx.idempotency[key] = order."
  "Ask your AI: 'make this create handler honor the Idempotency-Key header using ctx.idempotency.'"
)
TASK_GOAL="Honor Idempotency-Key so a retried create returns the same order — edit ~/workspace/handlers/idempotent.py"
setup() { seed_handler "idempotent.py"; }
check() {
  if run_harness idempotent "$HANDLERS/idempotent.py"; then
    pass "same key -> same order (no duplicate); a new key -> a new order. Creates are now safe to retry."
  else
    fail "implement the Idempotency-Key logic in ~/workspace/handlers/idempotent.py (see failing checks above), then run lesson check"
    return 1
  fi
}
