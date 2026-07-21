# shellcheck shell=bash disable=SC2034
TASK_TITLE="Own the contract"
TASK_CAT="Contract-first"
TASK_BODY="In Module 4 you READ a contract; here you OWN one. Open the orders
contract in your workspace:
  less ~/workspace/orders-api.yaml

It is the single source of truth for how the service must behave. Read the design
rules at the top and the schemas. Notice what is deliberately ABSENT from the
create payload (NewOrder): no price, no total, no status. Those are
SERVER-AUTHORITATIVE — the client never sets them. Reads of an order are
owner-only; writes need a bearer token (alice-token or bob-token).

A flawed server is already running at http://localhost:8080. Over this module you
make it match this contract. First, understand the contract. When you have, run
'lesson check' — it'll ask you one question about it."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="The contract is the artifact you design before code and defend after.
Owning it is the senior move: the AI can write handlers, but YOU decide the
shape, the error cases, and — above all — the trust rules."
TASK_HINTS=(
  "Look at the NewOrder schema and the description on totalCents in the Order schema."
  "The contract says totalCents is 'Computed by the server' — the client only sends items."
)
TASK_QUIZ="Per the contract, who determines an order's total price?"
TASK_QUIZ_OPTIONS=(
  "The client sends the total in the request body"
  "The server computes it from the product catalog"
  "Whichever total is larger, the client's or server's"
  "It is agreed during a preflight handshake first"
)
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="The server computes the total from catalog prices. Price/total/status are server-authoritative; the client sends only items."
setup() { seed_contract; }
