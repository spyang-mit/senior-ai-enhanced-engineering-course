# shellcheck shell=bash disable=SC2034
TASK_TITLE="Status-code discipline"
TASK_CAT="Contract-first"
TASK_BODY="Status codes are part of the contract — they tell a client what
happened without parsing the body. The ones this API uses:
  200 OK          a read (or an idempotent replay) succeeded
  201 Created     a new resource was made
  204 No Content  success, nothing to return
  400 Bad Request the body was malformed / failed validation
  401 Unauthorized no or invalid credentials ('who are you?')
  403 Forbidden   authenticated, but not allowed ('not for you')
  404 Not Found   no such resource (also: hiding someone else's resource)
  409 Conflict    the request clashes with current state

Read those, then run 'lesson check' for a question. (These recur throughout the
module — getting them right is half of API design.)"
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="Wrong codes are a real bug: a client that retries on 200-but-actually-
failed, or treats a 400 as a 500 and pages an engineer at 3am. Honest codes are
how systems coordinate."
TASK_HINTS=(
  "The token was valid, so it isn't 401. The request reached the server fine; the problem is the CONTENT."
  "An empty items list is a malformed request — the classic 'bad request' code."
)
TASK_QUIZ="A create arrives with a valid token but an empty items list. Which status should the server return?"
TASK_QUIZ_OPTIONS=(
  "401 Unauthorized"
  "404 Not Found"
  "400 Bad Request"
  "201 Created"
)
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="400 Bad Request — the credentials were fine, but the body failed validation. (401 is for auth; 404 is for missing resources.)"
setup() { seed_contract; }
