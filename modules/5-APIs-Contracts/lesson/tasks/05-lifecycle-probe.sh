# shellcheck shell=bash disable=SC2034
TASK_TITLE="Request lifecycle; where validation lives"
TASK_CAT="Validation & correct codes"
TASK_BODY="Every HTTP request follows the same lifecycle on the server:

  1. Parse the request line (method + path)
  2. Parse headers (auth, content-type, etc.)
  3. Parse the body (if any)
  4. VALIDATE the input (before touching data)
  5. Execute the business logic
  6. Return the response

Validation lives at step 4 — BETWEEN parsing and execution. If you validate too
late (after touching data), you may have started a transaction you can't undo.
If you validate too early (before parsing), you reject valid requests.

Probe the current server to see what happens when you send BAD input:
  • Create an order with qty=0:       curl -s -X POST .../orders ...
  • Create with unknown productId:    curl -s -X POST .../orders ...
  • Create without auth:              curl -s -X POST .../orders ...

Observe what the server does with each. Then answer the question."
TASK_TRY="curl -s -X POST http://localhost:8080/orders -H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' -d '{\"items\":[{\"productId\":1,\"qty\":0}]}'"
TASK_WHY="You can't harden what you haven't observed. Probing the naive server
shows you exactly where validation is missing — and why it matters."
TASK_HINTS=(
  "Try qty=0, qty=-1, and an unknown productId like 999. What status comes back?"
  "Try sending a body with no items field at all: -d '{}'"
  "Compare what you see with what the contract says should happen."
)
TASK_QUIZ="What status does the current (naive) server return when you POST with qty=0?"
TASK_QUIZ_OPTIONS=("200 OK" "400 Bad Request" "404 Not Found" "500 Server Error")
TASK_QUIZ_ANSWER=0
TASK_QUIZ_EXPLAIN="200 OK — the naive server accepts qty=0 (and even qty=-1) without validation. It doesn't validate at the boundary yet; that's Task 6."
