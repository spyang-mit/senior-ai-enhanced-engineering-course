# shellcheck shell=bash disable=SC2034
TASK_TITLE="Update with PUT"
TASK_CAT="HTTP with curl"
TASK_BODY="PUT updates an existing contact — you send the full contact and the
server replaces it. Change contact 1's phone number (writes need the token):
  curl -s -X PUT http://localhost:8080/contacts/1 \\
    -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' \\
    -d '{\"firstName\":\"Ada\",\"lastName\":\"Lovelace\",\"phone\":\"555-0001\"}'

Then confirm it took:
  curl -s http://localhost:8080/contacts/1 | jq -r .phone

Notice PUT is IDEMPOTENT: run that exact PUT again and nothing further changes —
the end state is the same. (Contrast POST, which creates a NEW row every time.)"
TASK_TRY="curl -s -X PUT http://localhost:8080/contacts/1 -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' -d '{\"firstName\":\"Ada\",\"lastName\":\"Lovelace\",\"phone\":\"555-0001\"}'"
TASK_WHY="PUT means 'make this resource look like X.' Because it sets an absolute
state, repeating it is safe (idempotent) — which matters when a request times
out and a client retries. POST isn't idempotent; retrying it can double-create."
TASK_GOAL="Update contact 1's phone to 555-0001 via PUT"
TASK_HINTS=(
  "PUT to /contacts/1 with the full contact body and the token, setting phone to 555-0001. Then GET it and check the phone."
  "curl -s http://localhost:8080/contacts/1 | jq -r .phone   should print 555-0001"
)
check() {
  if [ "$(curl -s "$API/contacts/1" | jq -r .phone 2>/dev/null)" = "555-0001" ]; then
    pass "contact 1's phone is now 555-0001 — PUT replaced it. Running that PUT again would change nothing (idempotent)."
  else
    fail "PUT contact 1 with phone 555-0001 (with the token), then confirm with: curl -s http://localhost:8080/contacts/1 | jq -r .phone"
    return 1
  fi
}
