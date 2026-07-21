# shellcheck shell=bash disable=SC2034
TASK_TITLE="Timeouts & retries"
TASK_CAT="Scale & failure"
TASK_BODY="Here's where it all connects. A client sends a create, then the network
hiccups and the response never arrives. The client is now stuck: did the order
get created or not? It CAN'T tell. Its only sane move is to RETRY.

That retry is safe only because you did the idempotency work: with an
Idempotency-Key, the second attempt returns the same order instead of making a
duplicate. Without it, every timeout risks a double order. Failure handling and
idempotency are two halves of one idea. Run 'lesson check' for a question."
TASK_TRY="less ~/workspace/handlers/10-idempotent.py"
TASK_WHY="You can't prevent timeouts; you can only make the recovery (a retry)
safe. That's why 'is this write idempotent?' is one of the first questions a
senior engineer asks about any endpoint."
TASK_HINTS=(
  "After a timeout the client doesn't know if the write landed, so it retries."
  "If the endpoint isn't idempotent, that retry can create a second copy of the thing."
)
TASK_QUIZ="A client's create times out with no response. Why is retrying safe ONLY if the endpoint is idempotent?"
TASK_QUIZ_OPTIONS=(
  "Retrying is never actually safe after a timeout occurs"
  "Timeouts can only occur on endpoints that are idempotent"
  "A non-idempotent retry might create a duplicate order"
  "Idempotent endpoints simply answer retries more quickly"
)
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="Because the client can't tell if the first attempt landed. On a non-idempotent endpoint, the retry would create a second order; idempotency makes the repeat harmless."
