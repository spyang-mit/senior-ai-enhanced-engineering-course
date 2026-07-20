# shellcheck shell=bash disable=SC2034
TASK_TITLE="Status codes"
TASK_CAT="HTTP with curl"
TASK_BODY="Every response carries a STATUS CODE — a 3-digit verdict on how the
request went:
  2xx success (200 OK, 201 Created, 204 No Content)
  3xx redirect      4xx you got it wrong (400, 401, 404)      5xx server broke
You saw the status line in 'curl -v'. For everyday use, -i ('include') is the
quick version — it prints the response's status line and headers, then the body,
without the request side:
  curl -s -i http://localhost:8080/contacts/1

The very first line is the status, e.g. 'HTTP/1.0 200 OK'. Now ask for a contact
that doesn't exist and read ITS status line:
  curl -s -i http://localhost:8080/contacts/999

Note the code you get for the missing one, then run 'lesson check'."
TASK_TRY="curl -s -i http://localhost:8080/contacts/999"
TASK_WHY="The status code is how a client knows what happened without reading the
body: 200 vs 404 vs 401 vs 500 = success / not-found / unauthorized / server bug.
It's the first thing you check when something's off — and the exact thing the
browser's Network tab shows for every request."
TASK_HINTS=(
  "curl -s -i shows the status line first. id 1 returns 200 OK; id 999 is a different code."
  "Asking for something that isn't there is the classic 'not found' — a 4xx code."
)
TASK_QUIZ="What status code does GET /contacts/999 (a contact that doesn't exist) return?"
TASK_QUIZ_OPTIONS=("200" "400" "404" "500")
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="404 Not Found — the resource isn't there. (200 = OK, 400 = bad request, 500 = server error.)"
