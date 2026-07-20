# shellcheck shell=bash disable=SC2034
TASK_TITLE="No token, no write (401)"
TASK_CAT="HTTP with curl"
TASK_BODY="The contract says writes require a bearer token. What happens if you
leave it off? Try the create from the last task but WITHOUT the Authorization
header, and use -i so you can read the status line:
  curl -s -i -X POST http://localhost:8080/contacts \\
    -H 'Content-Type: application/json' \\
    -d '{\"firstName\":\"No\",\"lastName\":\"Auth\",\"phone\":\"555-0\"}'

The server rejects it — nothing gets created. Read the status line, then run
'lesson check'."
TASK_TRY="curl -s -i -X POST http://localhost:8080/contacts -H 'Content-Type: application/json' -d '{\"firstName\":\"No\",\"lastName\":\"Auth\",\"phone\":\"555-0\"}'"
TASK_WHY="This code is the server refusing an unauthenticated write — the trust
boundary in action. Reads here are open, but writes demand a credential. (401 =
'who are you?'; its cousin 403 = 'I know who you are, but you still can't.')"
TASK_HINTS=(
  "Run the POST with -i but no Authorization header; read the first line."
  "No credentials supplied → the server says you're unauthorized."
)
TASK_QUIZ="A write with NO Authorization header comes back with which status?"
TASK_QUIZ_OPTIONS=("401" "400" "403" "500")
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="401 Unauthorized — no valid token, so the server refused the write. That's the auth boundary."
