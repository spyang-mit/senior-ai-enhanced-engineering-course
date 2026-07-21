# shellcheck shell=bash disable=SC2034
TASK_TITLE="The contract is the artifact"
TASK_CAT="Contract-first"
TASK_BODY="Before any code, there is the CONTRACT — the YAML spec that describes
every endpoint, its request body, and its responses. It lives at
workspace/orders-api.yaml on your host machine.

Open it in an editor or AI session on your host. Read through it. Notice:
  • Which endpoints exist (and which are deliberately MISSING — cancel, refund)
  • Which error cases are documented (400, 401, 404 — and which are NOT: 403, 409)
  • The schemas for Product, Order, and NewOrder

Then answer the question."
TASK_TRY="cat workspace/orders-api.yaml"
TASK_WHY="The contract is a first-class artifact — you author it before code, and
the server implements what it says. In Module 4 you READ a contract; in Module 5
you WRITE one. Every task starts with the contract, then the code follows."
TASK_HINTS=(
  "Open workspace/orders-api.yaml in an editor on your host machine. Look at the paths section — which endpoints are documented?"
  "Compare against the list in the plan: products, orders (get+post), orders/{id} (get). What's missing?"
  "Look at the responses section for each endpoint. Which status codes are documented? Which aren't?"
)
TASK_QUIZ="How many endpoint paths are currently documented in orders-api.yaml?"
TASK_QUIZ_OPTIONS=("1" "2" "3" "4")
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="Three paths: /products (GET), /orders (GET+POST), /orders/{id} (GET). POST /orders/{id}/cancel and POST /orders/{id}/refund are intentionally missing — you'll add them."
