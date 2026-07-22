# shellcheck shell=bash disable=SC2034
TASK_TITLE="Return honest status codes"
TASK_CAT="Validation & codes"
TASK_BODY="The naive server lies about outcomes. Watch it return 200 for a
CREATE (should be 201), and 200 for a missing order (should be 404):
  curl -s -i -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' \\
    -d '{\"items\":[{\"productId\":1,\"qty\":1}]}'   | head -1
  curl -s -i localhost:8080/orders/999999 -H 'Authorization: Bearer alice-token' | head -1

A client can't tell success-that-created from success-that-did-nothing, or
missing-resource from empty-result. Fix the codes in:
  ~/workspace/handlers/codes.py
A successful create must return 201; a GET for a nonexistent order must return
404. Edit it, then run 'lesson check'."
TASK_TRY="curl -s -i -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{\"items\":[{\"productId\":1,\"qty\":1}]}' | head -1"
TASK_WHY="Codes are the contract's promises about outcomes. 201 vs 200 tells a
client whether something was created; 404 vs 200 tells it whether a thing exists.
Automation (retries, caches, monitoring) all key off the code, not the body."
TASK_HINTS=(
  "In ~/workspace/handlers/codes.py there are two TODOs: the POST branch and the GET branch."
  "A successful create returns (201, order); a GET with no matching order returns (404, {\"error\": ...})."
)
TASK_GOAL="Return 201 on create and 404 on a missing order — edit ~/workspace/handlers/codes.py"
setup() { seed_handler "codes.py"; }
check() {
  if run_harness codes "$HANDLERS/codes.py"; then
    pass "create -> 201, missing -> 404. Your codes now tell the truth about what happened."
  else
    fail "fix the status codes in ~/workspace/handlers/codes.py (see the failing checks above), then run lesson check"
    return 1
  fi
}
