# shellcheck shell=bash disable=SC2034
TASK_TITLE="Author an error case (409)"
TASK_CAT="Contract-first"
TASK_BODY="A contract is only as good as its error cases. The create endpoint is
missing one it will need: a 409 Conflict — returned when a client reuses an
Idempotency-Key with a DIFFERENT body (a genuine conflict with existing state).

Design it into the contract. In ~/workspace/orders-api.yaml, under
paths -> /orders -> post -> responses, add a '409' response with a description
(reuse the Error schema for its body, like the 400 does).

This is contract-FIRST: you specify the behavior before any handler implements
it. Edit the file in your workspace (your editor / AI on the host), then run
'lesson check'."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="Naming your failure modes up front is how callers learn to handle them.
'What are all the ways this can fail, and what does each return?' is a design
question you answer in the contract, not a thing you discover in production."
TASK_GOAL="Add a 409 Conflict response to POST /orders in ~/workspace/orders-api.yaml"
TASK_HINTS=(
  "Find the 'responses:' block under the post: on /orders. It already lists 201, 400, 401 — add a sibling '409:' at the same indentation."
  "Copy the shape of the existing '400:' entry (description + content + Error schema) and change the code to 409 and the description."
  "Ask your AI: 'add a 409 Conflict response to POST /orders in this OpenAPI file, mirroring the 400 response.'"
)
setup() { seed_contract; }
check() {
  if ! contract_valid; then
    fail "orders-api.yaml isn't valid YAML anymore — check your indentation (try: python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' ~/workspace/orders-api.yaml)"
    return 1
  fi
  if contract_has_409_on_post_orders; then
    pass "POST /orders now documents a 409 Conflict. You designed the error case before writing a line of handler."
  else
    fail "add a '409' entry under paths -> /orders -> post -> responses in ~/workspace/orders-api.yaml"
    return 1
  fi
}
