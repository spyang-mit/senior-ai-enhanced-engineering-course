# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create with POST"
TASK_CAT="HTTP with curl"
TASK_BODY="GET reads; POST creates. To create a contact you send a POST with a
JSON body — and, per the contract, writes need a bearer token
(Authorization: Bearer let-me-in).

Create a contact named Bea Bumble:
  curl -s -X POST http://localhost:8080/contacts \\
    -H 'Authorization: Bearer let-me-in' \\
    -H 'Content-Type: application/json' \\
    -d '{\"firstName\":\"Bea\",\"lastName\":\"Bumble\",\"phone\":\"555-2025\"}'

  -X POST         choose the method
  -H ...          add request headers (the token + telling the server it's JSON)
  -d '{...}'      the request body
A successful create returns 201 and the new contact (with an assigned id). Add
-i if you want to see that status line."
TASK_TRY="curl -s -X POST http://localhost:8080/contacts -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' -d '{\"firstName\":\"Bea\",\"lastName\":\"Bumble\",\"phone\":\"555-2025\"}'"
TASK_WHY="POST is how clients add data. Its three moving parts — the method, the
headers (auth + content type), and a JSON body — are the same for every write
API you'll ever hit. 201 Created is the success code for 'made something new.'"
TASK_GOAL="Create Bea Bumble via POST and confirm she appears in the list"
TASK_HINTS=(
  "Copy the multi-line curl from the task (method, both -H headers, and the -d body). It returns the new contact."
  "Forgot the Authorization header? You'll get 401 instead — that's the next task."
)
check() {
  if curl -s "$API/contacts" | jq -e 'any(.[]; .lastName=="Bumble")' >/dev/null 2>&1; then
    pass "created — Bea Bumble is now in the list (a 201 and a real new row). POST works."
  else
    fail "create the Bea Bumble contact with a POST (remember the Authorization: Bearer let-me-in header)"
    return 1
  fi
}
