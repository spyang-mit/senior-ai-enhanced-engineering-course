# shellcheck shell=bash disable=SC2034
TASK_TITLE="Websocket caveats"
TASK_CAT="Real-time"
TASK_BODY="Websockets are powerful but not magic, and AI-generated real-time code
often ignores their failure modes:
  • A dropped connection can miss messages — there's no built-in replay of what
    you didn't receive while disconnected.
  • You must handle reconnection yourself (and often re-sync state on reconnect).
  • Ordering guarantees are limited, especially relative to other channels.
Because of this, a common design keeps the REST API as the source of TRUTH and
treats websocket pushes as a live hint — on reconnect, you re-fetch to be sure.
Run 'lesson check' for a question."
TASK_TRY="less ~/workspace/ws-listen.py"
TASK_WHY="'It worked on my machine for ten seconds' is not the same as 'it's
correct under a flaky mobile connection.' Knowing what a websocket does NOT
guarantee is what lets you verify real-time features instead of trusting them."
TASK_HINTS=(
  "Think about what happens to pushed messages while the client is briefly disconnected."
  "Unlike a re-runnable request, a missed push isn't automatically re-delivered."
)
TASK_QUIZ="What's a real caveat of websockets vs. plain request/response?"
TASK_QUIZ_OPTIONS=(
  "They can only carry plain text, never JSON data"
  "A dropped connection can miss pushes, with no built-in replay"
  "They must open a brand-new TCP connection for each message sent"
  "They work only between two servers, never with a browser"
)
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="A disconnect can silently drop pushed messages — nothing replays them automatically, so you reconnect and re-sync from the source of truth."
