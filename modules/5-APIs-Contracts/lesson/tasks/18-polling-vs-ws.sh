# shellcheck shell=bash disable=SC2034
TASK_TITLE="Polling vs. WebSocket"
TASK_CAT="Real-time (light, guided)"
TASK_BODY="A client wants to watch an order's status change (pending → paid →
shipped → delivered) without refreshing the page. Two approaches:

  1. POLLING — the client asks every N seconds: GET /orders/{id}.
     Simple, reliable, but wasteful (most polls return nothing new).

  2. WEBSOCKET — the client opens a persistent connection and the SERVER pushes
     updates when they happen. Efficient (no wasted polls) but more complex.

The module plan includes a minimal websocket server for demonstration. Observe
the difference between polling and a WS stream using websocat.

First, POLL for an order status (it stays 'pending' until something changes):
  curl -s http://localhost:8080/orders/1 -H 'Authorization: Bearer alice-token'

Then, observe the WS stream (if available on the server). The key insight is
delivery semantics — with polling you always get the latest state; with WS you
may miss a message if you disconnect.

Then answer."
TASK_TRY="curl -s http://localhost:8080/orders/1 -H 'Authorization: Bearer alice-token'"
TASK_WHY="Polling vs WebSocket is a real-time design decision. Polling is simple
but wasteful; WS is efficient but has delivery/ordering caveats. You need to
understand both to choose the right one for a given feature."
TASK_HINTS=(
  "Polling: GET /orders/{id} every N seconds. Always returns the current state."
  "WebSocket: server pushes state changes. If you disconnect, you miss the update — unless the server replays recent events."
)
TASK_QUIZ="What is the key difference between polling and WebSocket for a status-update feature?"
TASK_QUIZ_OPTIONS=(
  "Polling always returns the current state; WebSocket may miss updates if disconnected"
  "Polling is faster; WebSocket is slower but more reliable"
  "Polling requires auth; WebSocket doesn't"
  "There is no difference — both deliver the same data the same way"
)
TASK_QUIZ_ANSWER=0
TASK_QUIZ_EXPLAIN="Polling: client asks, server answers — you always get the current state, but you pay for every poll. WebSocket: server pushes when state changes — efficient, but if you disconnect you miss the update unless the server replays history."
