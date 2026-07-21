# shellcheck shell=bash disable=SC2034
TASK_TITLE="Status-code discipline"
TASK_CAT="Contract-first"
TASK_BODY="Every HTTP response carries a status code — the machine-readable verdict.
Writing a contract means choosing the RIGHT code for each case, not just '200 OK'
for everything.

From the contract you just read, match each scenario to its correct status code:

  • Creating a new order successfully → ?
  • Reading a single order that exists → ?
  • Reading an order that doesn't exist → ?
  • Sending a bad request body → ?
  • Missing/invalid auth → ?
  • Auth valid but order belongs to another user → ?
  • Trying to cancel an order that can't be cancelled → ?

Then answer the question."
TASK_WHY="Status-code discipline is how a contract communicates success/failure
semantics without the client reading the body. 201 vs 200 is the difference
between 'new thing created' and 'here is the thing.' Getting codes wrong means
the client can't tell what happened."
TASK_HINTS=(
  "201 Created vs 200 OK — the distinction is whether a NEW resource was created."
  "404 Not Found vs 403 Forbidden — one means 'doesn't exist,' the other means 'exists but you may not see it.'"
  "409 Conflict is for idempotency mismatches and wrong-status transitions."
)
TASK_QUIZ="Which status code should POST /orders return on successful creation?"
TASK_QUIZ_OPTIONS=("200 OK" "201 Created" "202 Accepted" "204 No Content")
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="201 Created — POST creates a new resource and should return 201 with the new resource in the body. 200 OK is for GET (read) and PUT (update)."
