# shellcheck shell=bash disable=SC2034
TASK_TITLE="Bad input (400)"
TASK_CAT="HTTP with curl"
TASK_BODY="Even with a valid token, the server checks your body. The contract
says firstName, lastName, and phone are all required. Send an incomplete body
and the server refuses it and returns a JSON error message — it does NOT create
a broken record.

Send a contact that's missing its phone (with the token), using -i to see the
status and the error body:
  curl -s -i -X POST http://localhost:8080/contacts \\
    -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' \\
    -d '{\"firstName\":\"Missing\",\"lastName\":\"Phone\"}'

Read the status line and the error message, then run 'lesson check'."
TASK_TRY="curl -s -i -X POST http://localhost:8080/contacts -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' -d '{\"firstName\":\"Missing\",\"lastName\":\"Phone\"}'"
TASK_WHY="This code means 'your request was malformed.' Validating input at the
boundary is how a server protects its data. A good API tells you WHAT was wrong
in the body — read that message instead of blindly retrying."
TASK_HINTS=(
  "You DID send a valid token, so it isn't an auth problem — the request itself is incomplete."
  "A malformed / incomplete request is a 'bad request' — a 4xx code that isn't 401 or 404."
)
TASK_QUIZ="A POST with a valid token but a missing required field returns which status?"
TASK_QUIZ_OPTIONS=("200" "400" "404" "500")
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="400 Bad Request — the token was fine, but the body failed validation. Data integrity starts at the boundary."
