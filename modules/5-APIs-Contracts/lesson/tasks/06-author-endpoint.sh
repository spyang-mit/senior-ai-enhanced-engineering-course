# shellcheck shell=bash disable=SC2034
TASK_TITLE="Author a new endpoint"
TASK_CAT="Contract-first"
TASK_BODY="The contract has no way to cancel an order yet. Design one. Add a new
path to ~/workspace/orders-api.yaml:

  POST /orders/{id}/cancel   — cancel one of your orders.

The '{id}' is a PATH PARAMETER — a placeholder, not a literal. A real request
substitutes an actual order id right there in the URL:
  POST /orders/4/cancel   cancels the order whose id is 4
  POST /orders/9/cancel   cancels order 9
So ONE path definition serves every order — the id travels IN the path (not the
body or a query string). In the contract you declare it once as a parameter with
'in: path'; in code it arrives as that order id (the req.order_id your handlers
will use later).

Specify it like the rest of the contract: the path parameter 'id', a
'post:' with a summary, bearerAuth security, and a 'responses:' block. Give it at
least a 2xx success (200 returning the Order, or 204 No Content) and the failure
cases that matter (401 no token, 404 not your order).

You're deciding the shape before any code exists. Edit the file, then run
'lesson check'."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="Adding an endpoint to the contract first — verbs, path shape, auth,
every response — is exactly how you'd brief an AI (or a teammate) to implement it
without inventing their own design. Contract first, code second."
TASK_HINTS=(
  "Model it on the existing '/orders/{id}:' block — it already shows the path 'id' parameter and a bearerAuth'd operation."
  "You need a NEW path key '/orders/{id}/cancel:' with a 'post:' under it (summary, security, responses with a 2xx)."
  "Ask your AI: 'add a POST /orders/{id}/cancel path to this OpenAPI contract: bearer auth, 200 returning an Order, plus 401 and 404.'"
)
TASK_GOAL="Add a POST /orders/{id}/cancel path (with a 2xx + failure responses) to the contract"
setup() { seed_contract; }
check() {
  if ! contract_valid; then
    fail "orders-api.yaml isn't valid YAML — check indentation with: python3 -c 'import yaml;yaml.safe_load(open(\"'\"$CONTRACT\"'\"))'"
    return 1
  fi
  if contract_has_cancel_path; then
    pass "POST /orders/{id}/cancel is now in the contract, with a success response. You designed the endpoint before implementing it."
  else
    fail "add a '/orders/{id}/cancel:' path with a 'post:' and at least one 2xx response to ~/workspace/orders-api.yaml"
    return 1
  fi
}
