# shellcheck shell=bash disable=SC2034
TASK_TITLE="A retry creates two orders"
TASK_CAT="Idempotency"
TASK_BODY="Networks fail. A client sends a create, the response is lost to a
timeout, so the client RETRIES. Watch what the naive server does with that.

Count your orders, create the same one twice, count again:
  A='Authorization: Bearer alice-token'
  curl -s localhost:8080/orders -H \"\$A\" | jq length
  curl -s -X POST localhost:8080/orders -H \"\$A\" -d '{\"items\":[{\"productId\":1,\"qty\":1}]}' >/dev/null
  curl -s -X POST localhost:8080/orders -H \"\$A\" -d '{\"items\":[{\"productId\":1,\"qty\":1}]}' >/dev/null
  curl -s localhost:8080/orders -H \"\$A\" | jq length

Two identical orders — a double charge waiting to happen. Run 'lesson check' for
a question about why."
TASK_TRY="curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{\"items\":[{\"productId\":1,\"qty\":1}]}'"
TASK_WHY="Retries are not optional — clients, proxies, and job queues all retry on
timeouts. If your create isn't safe to repeat, every flaky network turns into
duplicate data. This is the problem idempotency solves."
TASK_HINTS=(
  "Each POST to /orders makes a brand-new order with a new id — the server has no idea it's a repeat."
  "So retrying a POST that already succeeded (you just didn't hear back) creates a second one."
)
TASK_QUIZ="Why is a plain POST /orders unsafe to retry?"
TASK_QUIZ_OPTIONS=(
  "POST is slower than the other HTTP verbs"
  "POST responses can never be cached by the client"
  "The server already rejects any repeated POST for you"
  "Each POST creates a new resource, so a retry duplicates it"
)
TASK_QUIZ_ANSWER=4
TASK_QUIZ_EXPLAIN="Each POST creates another resource. A retry after a lost response makes a second order — unless you add idempotency."
