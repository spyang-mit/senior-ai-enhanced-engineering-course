# shellcheck shell=bash disable=SC2034
TASK_TITLE="Which methods are idempotent"
TASK_CAT="Idempotency"
TASK_BODY="A request is IDEMPOTENT when doing it again leaves the same end state:
  GET     read — repeating changes nothing
  PUT     'set this resource to X' — same result every time
  DELETE  'make it gone' — gone stays gone
  POST    'create a new one' — repeating makes ANOTHER (not idempotent)

Cancel is a 'set to cancelled', so it's idempotent — try it twice:
  A='Authorization: Bearer alice-token'
  curl -s -X POST localhost:8080/orders/1/cancel -H \"\$A\" | jq .status
  curl -s -X POST localhost:8080/orders/1/cancel -H \"\$A\" | jq .status
Same end state both times. Run 'lesson check' for a question."
TASK_TRY="curl -s -X POST localhost:8080/orders/1/cancel -H 'Authorization: Bearer alice-token' | jq .status"
TASK_WHY="Idempotency is what makes retries SAFE. A client (or proxy) can resend
an idempotent request after a timeout without fear. Knowing which verbs are
naturally idempotent — and making your writes behave that way — is core API
design."
TASK_HINTS=(
  "GET, PUT, and DELETE all land the same end state no matter how many times you repeat them."
  "The odd one out is the verb whose whole job is to create a NEW resource each time."
)
TASK_QUIZ="Which HTTP method is NOT naturally idempotent?"
TASK_QUIZ_OPTIONS=("GET" "PUT" "DELETE" "POST")
TASK_QUIZ_ANSWER=4
TASK_QUIZ_EXPLAIN="POST. GET/PUT/DELETE leave the same end state when repeated; POST creates another resource each time."
