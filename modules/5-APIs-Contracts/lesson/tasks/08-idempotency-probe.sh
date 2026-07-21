# shellcheck shell=bash disable=SC2034
TASK_TITLE="See the idempotency bug"
TASK_CAT="Idempotency (marquee)"
TASK_BODY="POST is NOT idempotent — creating the same order twice should produce
TWO orders, but what happens when a NETWORK TIMEOUT causes a retry? The client
doesn't know if the first POST succeeded, so it sends the same request again.
With a naive server, the retry creates a DUPLICATE order — you get charged twice.

Prove it: create TWO identical orders and observe they have different IDs:
  curl -s -X POST http://localhost:8080/orders \\
    -H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' \\
    -d '{"items":[{"productId":1,"qty":1}]}'

Do it TWICE. Compare the response — same items, different order ids. Then answer."
TASK_TRY="curl -s -X POST http://localhost:8080/orders -H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' -d '{\"items\":[{\"productId\":1,\"qty\":1}]}'"
TASK_WHY="This is the idempotency problem. POST creates a new resource every time.
If the client retries after a timeout, they get two orders instead of one. The
fix is to make POST idempotent via an Idempotency-Key header."
TASK_HINTS=(
  "Create two orders with the same items. Check the 'id' field in each response."
  "If ids differ, each POST created a new order — the server is not idempotent."
)
TASK_QUIZ="Why is POST inherently NOT idempotent, unlike PUT?"
TASK_QUIZ_OPTIONS=(
  "POST creates a new resource each time; PUT replaces the same resource"
  "POST is a read-only method; PUT writes"
  "POST doesn't require auth; PUT does"
  "POST can return any status code; PUT always returns 200"
)
TASK_QUIZ_ANSWER=0
TASK_QUIZ_EXPLAIN="POST creates a new resource — so every successful POST produces a new id. PUT replaces an existing resource at a known URL, so the same PUT twice yields the same state. That's why PUT is idempotent by default and POST isn't."
