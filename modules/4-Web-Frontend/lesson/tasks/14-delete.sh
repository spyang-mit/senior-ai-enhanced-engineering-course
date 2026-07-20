# shellcheck shell=bash disable=SC2034
TASK_TITLE="Remove with DELETE"
TASK_CAT="HTTP with curl"
TASK_BODY="DELETE removes a resource. Delete contact 2 (writes need the token);
use -i to see the status:
  curl -s -i -X DELETE http://localhost:8080/contacts/2 \\
    -H 'Authorization: Bearer let-me-in'

A successful delete returns 204 No Content — success, with an empty body (there's
nothing left to send back, so there's no JSON under the headers). Confirm it's
really gone:
  curl -s -i http://localhost:8080/contacts/2
That GET should now show 404."
TASK_TRY="curl -s -i -X DELETE http://localhost:8080/contacts/2 -H 'Authorization: Bearer let-me-in'"
TASK_WHY="DELETE completes the CRUD set (Create/Read/Update/Delete = POST/GET/
PUT/DELETE). 204 means 'done, nothing to return.' Verifying with a follow-up GET
(now 404) is the habit: don't trust that a write worked — check the new state."
TASK_GOAL="Delete contact 2 and verify it returns 404"
TASK_HINTS=(
  "DELETE /contacts/2 with the token (expect 204), then GET /contacts/2 and confirm it's 404."
  "The check just confirms contact 2 is gone (a GET for it returns 404)."
)
check() {
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "$API/contacts/2")" = "404" ]; then
    pass "contact 2 is gone — DELETE removed it (204), and a follow-up GET confirms 404. That's the whole CRUD set."
  else
    fail "delete contact 2 (with the token), then verify a GET for /contacts/2 returns 404"
    return 1
  fi
}
