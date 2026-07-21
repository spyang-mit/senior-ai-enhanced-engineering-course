# shellcheck shell=bash disable=SC2034
TASK_TITLE="PUT and cancel are idempotent by design"
TASK_CAT="Idempotency (marquee)"
TASK_BODY="PUT replaces a resource at a known URL — so the same PUT twice returns
the same state. That's idempotent BY DEFINITION, no extra machinery needed.

Similarly, cancelling an order that's already cancelled should return the same
cancelled state — not flip back to 'pending.'

Prove the current cancel is BROKEN (it flip-flops):
  1. Create an order: POST /orders
  2. Cancel it:      POST /orders/{id}/cancel
  3. Cancel it AGAIN: POST /orders/{id}/cancel

What status do you get the second time? Then answer."
TASK_TRY="curl -s -X POST http://localhost:8080/orders/1/cancel -H 'Authorization: Bearer alice-token'"
TASK_WHY="Idempotency means 'same request, same result.' Cancel should be idempotent:
cancelling twice is the same as cancelling once. The current server flip-flops
(pending → cancelled → pending → cancelled...), which is the idempotency bug."
TASK_HINTS=(
  "Create an order, cancel it, cancel it again. Compare the status field."
  "If the second cancel changes status back to 'pending', the cancel is NOT idempotent."
)
TASK_QUIZ="What happens when you cancel the SAME order twice on the naive server?"
TASK_QUIZ_OPTIONS=(
  "The second cancel returns the same cancelled state (idempotent)"
  "The second cancel changes status back to 'pending' (flip-flop)"
  "The second cancel returns 404 — order is gone"
  "The second cancel returns 500 — server crash"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="The naive cancel flip-flops: pending → cancelled → pending → cancelled. That's the bug — cancel should be idempotent, meaning cancelling twice is the same as cancelling once."
