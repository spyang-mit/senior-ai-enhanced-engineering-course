# shellcheck shell=bash disable=SC2034
TASK_TITLE="Author a 409 Conflict error case"
TASK_CAT="Contract-first"
TASK_BODY="The contract is missing a '409 Conflict' response for POST /orders.
This matters: when a create fails because of an idempotency-key mismatch or a
status-transition conflict, the server needs to say '409 Conflict' — not a
generic 400 or 500.

Open workspace/orders-api.yaml on your host and ADD a 409 response to the
POST /orders path. It should:
  • Have description: 'Conflict — e.g. duplicate idempotency-key mismatch'
  • Return an Error body (reference #/components/schemas/Error)

Then save and run lesson check."
TASK_TRY="Edit workspace/orders-api.yaml on your host"
TASK_WHY="Adding error cases to the contract before code means the server and
client agree on what 'conflict' looks like. If the contract doesn't say 409, the
client doesn't know to handle it — and the server has no obligation to emit it."
TASK_GOAL="Add a 409 response to the POST /orders path in the YAML"
TASK_HINTS=(
  "Look at the existing 400 response under POST /orders — it's a template. Add a 409 entry with the same structure but different description."
  "The YAML structure: under responses, add '409:' with description and content/application/json/schema pointing to Error."
  "Indentation matters in YAML — match the indentation of the 400 entry exactly."
)
needs_server() { false; }
check() {
  local yaml="$WORKSPACE/orders-api.yaml"
  if [ ! -f "$yaml" ]; then
    fail "workspace/orders-api.yaml doesn't exist — did you remove it?"
    return 1
  fi
  if grep -qE "'409'|\"409\"|^    409:" "$yaml" 2>/dev/null; then
    pass "orders-api.yaml now contains a 409 response for POST /orders"
  elif grep -qE "409" "$yaml" 2>/dev/null; then
    pass "orders-api.yaml mentions 409"
  else
    fail "orders-api.yaml doesn't contain a 409 response yet — edit it on your host, then run lesson check"
    return 1
  fi
}
