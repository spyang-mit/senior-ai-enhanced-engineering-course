# shellcheck shell=bash disable=SC2034
TASK_TITLE="Timeouts & retries — why retries demand idempotency"
TASK_CAT="Scale & failure semantics"
TASK_BODY="A client sends a POST to create an order. The network stalls. After 10
seconds, the client's timeout fires — but the server MAY have received the request
and created the order. The client doesn't know.

The client RETRIES. Without idempotency:
  • If the first request DID reach the server → the retry creates a DUPLICATE order
  • If the first request DID NOT reach the server → the retry creates the order (good)

The client CANNOT tell which case happened. That's why POST (non-idempotent) is
dangerous with retries — and why Idempotency-Key exists.

Probe: simulate what happens when a timeout causes a retry by creating the same
order twice without an idempotency key. You already did this in Task 8. Now think
about what would happen in a real system with retries.

Then answer."
TASK_WHY="This ties together the marquee concept: idempotency is not optional when
retries exist. Every payment API, every order system, every create-with-retry
path needs idempotency — because the alternative is double charges."
TASK_HINTS=(
  "Task 8 showed that two identical POSTs create two different orders. Now imagine the client retried automatically after a timeout."
  "Without an idempotency key, the client can't deduplicate — and the server can't tell it's a retry."
)
TASK_QUIZ="A client retries a POST /orders after a timeout. Without idempotency, what's the worst case?"
TASK_QUIZ_OPTIONS=(
  "The order is lost — both requests fail"
  "Two orders are created — the customer gets charged twice"
  "The server returns an error — it detects the duplicate"
  "Nothing bad happens — POST is safe to retry"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="The worst case is the first request succeeded but the client timed out waiting for the response. The retry creates a second order — a duplicate. That's why POST needs Idempotency-Key: so the server can recognize a retry and return the same order, not a new one."
