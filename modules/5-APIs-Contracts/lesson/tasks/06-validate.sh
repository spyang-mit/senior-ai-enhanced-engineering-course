# shellcheck shell=bash disable=SC2034
TASK_TITLE="Validate at the boundary"
TASK_CAT="Validation & codes"
TASK_BODY="See the flaw first. Send the naive server nonsense — a zero quantity,
an unknown product — with a valid token:
  curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' \\
    -d '{\"items\":[{\"productId\":999,\"qty\":0}]}'
It happily creates the order. That's a corrupt record the rest of the system will
trip over later.

Now harden it. Your create handler lives in the mounted workspace:
  ~/workspace/handlers/06-validate.py
Edit it on your HOST (your editor, or point your AI at the file and the
contract). Per the contract, reject with 400 + an {\"error\": ...} body when
items is empty, any qty < 1, or a productId isn't in the catalog. Then come back
here and run 'lesson check' — it fires good and bad requests at your handler."
TASK_TRY="curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{\"items\":[{\"productId\":999,\"qty\":0}]}'"
TASK_WHY="Validation is the cheapest bug you'll ever prevent. A server that
refuses malformed input with a clear 400 protects every layer behind it — and
tells the caller exactly what to fix instead of failing mysteriously later."
TASK_HINTS=(
  "Open ~/workspace/handlers/06-validate.py — the TODO marks exactly where to add checks, before the order is built."
  "Return (400, {\"error\": \"...\"}) when items is empty, any qty < 1, or a productId is not in ctx.products."
  "Ask your AI: 'implement the validation in this handler per the contract: 400 on empty items, qty<1, or unknown productId.'"
)
TASK_GOAL="Make POST /orders reject bad input with 400 — edit ~/workspace/handlers/06-validate.py"
setup() { seed_handler "06-validate.py"; }
check() {
  if run_harness validate "$HANDLERS/06-validate.py"; then
    pass "your handler now rejects bad input with 400 and accepts good input with a server-computed total. That's the boundary doing its job."
  else
    fail "edit ~/workspace/handlers/06-validate.py so bad input returns 400 (see the failing checks above), then run lesson check"
    return 1
  fi
}
