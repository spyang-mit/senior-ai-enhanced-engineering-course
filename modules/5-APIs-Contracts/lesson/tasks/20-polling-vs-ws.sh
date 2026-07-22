# shellcheck shell=bash disable=SC2034
TASK_TITLE="Polling vs. websockets"
TASK_CAT="Real-time"
TASK_BODY="To show a live order status, a client has two options. See both.

POLLING — ask again and again over the REST API (order 1's status cycles for the
demo). Run this a few times, a second or two apart:
  curl -s localhost:8080/orders/1 -H 'Authorization: Bearer alice-token' | jq .status

WEBSOCKET — open one connection and let the SERVER push updates to you. Run:
  python3 ~/workspace/ws-listen.py       (Ctrl-C to stop)
You didn't ask repeatedly; the server spoke on its own. That's the difference:
polling is the client pulling on a timer; a websocket is a persistent two-way
connection the server can push over. Run 'lesson check' for a question."
TASK_TRY="python3 ~/workspace/ws-listen.py"
TASK_WHY="Polling is simple and stateless but wastes requests and lags between
polls. Websockets give instant, server-initiated updates at the cost of holding a
connection and handling reconnects. Choosing correctly is an architecture call."
TASK_HINTS=(
  "Polling means re-requesting on a timer even when nothing changed; a websocket pushes only when there's news."
  "Websockets shine when updates are frequent and you want them the instant they happen."
)
TASK_QUIZ="When is a websocket the better fit than polling?"
TASK_QUIZ_OPTIONS=(
  "When updates are frequent and you want them pushed instantly"
  "When you fetch the resource only once and never again"
  "When you want the simplest possible one-off request"
  "When the server must never send anything on its own"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="Frequent, latency-sensitive updates favor a pushed websocket. For one-off or rare reads, plain polling/requests are simpler and cheaper."
