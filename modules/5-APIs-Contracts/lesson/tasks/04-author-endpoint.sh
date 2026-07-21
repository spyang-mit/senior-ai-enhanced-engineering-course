# shellcheck shell=bash disable=SC2034
TASK_TITLE="Author an endpoint: POST /orders/{id}/cancel"
TASK_CAT="Contract-first"
TASK_BODY="The contract is missing the cancel endpoint. Add POST /orders/{id}/cancel
to workspace/orders-api.yaml.

This endpoint:
  • Takes no request body (cancellation is an action, not a data change)
  • Requires bearer auth
  • Returns 200 + the updated Order on success
  • Returns 404 if the order doesn't exist
  • Returns 409 if the order can't be cancelled (wrong status)

Add the path, parameters, and responses. Then run lesson check."
TASK_WHY="Adding an endpoint to the contract is the real skill: you design the
interface BEFORE implementing it. The code follows the contract, not the other
way around. Here you design what cancel looks like — then in later tasks you
implement the handler."
TASK_GOAL="Add POST /orders/{id}/cancel to orders-api.yaml with correct responses"
TASK_HINTS=(
  "Look at how /orders/{id} is defined — it uses parameters with 'id' as a path variable. Your cancel endpoint needs the same parameter."
  "POST /orders/{id}/cancel — the path has three segments: orders, {id}, cancel. Define it under paths: with the full path."
  "The cancel endpoint needs 200 (success + order), 401 (no auth), 404 (not found), 409 (conflict). No requestBody is needed."
)
needs_server() { false; }
check() {
  local yaml="$WORKSPACE/orders-api.yaml"
  if [ ! -f "$yaml" ]; then
    fail "workspace/orders-api.yaml doesn't exist"
    return 1
  fi
  if grep -qE "/orders/\{id\}/cancel" "$yaml" 2>/dev/null; then
    pass "orders-api.yaml now contains POST /orders/{id}/cancel"
  else
    fail "orders-api.yaml doesn't contain /orders/{id}/cancel yet — add the path with its responses"
    return 1
  fi
}
