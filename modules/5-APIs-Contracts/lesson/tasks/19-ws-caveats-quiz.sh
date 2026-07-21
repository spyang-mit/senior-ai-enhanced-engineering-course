# shellcheck shell=bash disable=SC2034
TASK_TITLE="WebSocket delivery/ordering caveats"
TASK_CAT="Real-time (light, guided)"
TASK_BODY="WebSocket is not a magic bullet. It has real caveats:

  1. DELIVERY — if the client disconnects briefly (e.g. phone locks screen), it
     MISSES the messages the server sent while disconnected. Unlike polling, there
     is no 're-fetch current state' — unless the server replays recent events on
     reconnect.
  2. ORDERING — messages arrive in the order the server sent them, but if the
     client processes them slowly (e.g. a heavy UI render), later messages may
     arrive before the client has finished processing earlier ones.
  3. RECONNECT — the client must detect disconnection and re-establish. During
     the gap, it has stale state.

These are not hypothetical — they are the real reasons many production systems
use polling or SSE (Server-Sent Events) instead of raw WebSockets, or use a
hybrid: WS for live updates + a GET endpoint for current state on reconnect.

Then answer."
TASK_WHY="WebSocket is a tool, not a solution. Knowing its caveats means you choose
it deliberately — not because 'real-time' sounds cool. The module is light on WS
because the hard real-time engineering (ordering, delivery guarantees, replay)
is deferred to Module 7."
TASK_HINTS=(
  "If a WS client disconnects for 2 seconds, what messages does it miss? How does it recover?"
  "Can a client receive message 'status=shipped' before it finished processing 'status=paid'?"
)
TASK_QUIZ="A WebSocket client briefly loses connection. What is the biggest risk?"
TASK_QUIZ_OPTIONS=(
  "The connection never recovers — the client is permanently disconnected"
  "The client misses messages sent during the gap and has stale state"
  "The server crashes — every disconnection restarts the server"
  "Nothing — WebSocket is designed for intermittent connections"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="If the server sent 'status=paid' and 'status=shipped' while the client was disconnected, the client misses both. On reconnect, the server sends only NEW messages — so the client never learns about those transitions unless the server replays history."
