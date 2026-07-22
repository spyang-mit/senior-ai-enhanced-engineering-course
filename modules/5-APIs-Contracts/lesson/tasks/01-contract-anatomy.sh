# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the contract: anatomy"
TASK_CAT="Contract-first"
TASK_BODY="In Module 4 you skimmed a contract; here you OWN one, so it's worth
understanding fully. Open it:
  less ~/workspace/orders-api.yaml

An OpenAPI contract has a few top-level sections:
  info        name + version of the API
  servers     the base URL(s) the API is reachable at
  components  reusable definitions (objects, security schemes) — defined ONCE
  paths       every URL and the operations (get/post/...) it supports

A path is written RELATIVE to the server base URL — the two combine to form the
real address. A path of /orders under a server of http://localhost:8080 means the
endpoint's full URL is http://localhost:8080/orders. That's what you (and every
client) actually call — exactly the curl targets you'll use all module.

The big idea: this one document IS the interface between client and server. Both
sides code against it, so they can be built — and tested — independently, without
either seeing the other's code. Skim the four sections, then run 'lesson check':
it'll ask a few questions (answer them across as many sessions as you like — it
remembers the ones you get right)."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="You can't own or defend a contract you can't read. Knowing where each
kind of information lives — endpoints vs. data shapes vs. servers — is the
foundation for authoring, implementing, and reviewing an API."
TASK_HINTS=(
  "Scroll the file top to bottom: find the info:, servers:, components:, and paths: keys at the left margin."
  "'paths:' holds the endpoints; 'components:' holds the reusable data objects."
)
setup() { seed_contract; }
quiz() {
  ask "Which top-level section lists the API's URLs and their operations (get/post/...)?" \
    "info" "servers" "components" "paths" \
    4 \
    "paths maps each URL (like /orders) to its operations. It's the catalog of endpoints."
  ask "What is the main payoff of writing this contract BEFORE the code?" \
    "It makes the server run measurably faster" \
    "Client and server can be built independently from one shared document" \
    "It removes the need to write any tests" \
    "It lets the browser skip CORS checks" \
    2 \
    "The contract is the interface. Both sides code to it, so they can be built and tested in parallel without seeing each other's code."
  ask "The servers: section lists http://localhost:8080. What is that?" \
    "The base URL that clients send their requests to" \
    "The database connection string the server uses internally" \
    "The list of user accounts allowed to log in" \
    "The folder where the server writes its logs" \
    1 \
    "servers gives the base URL(s) the API answers on; every path hangs off it."
  ask "Where does the contract keep its reusable object definitions?" \
    "paths" "info" "components" "servers" \
    3 \
    "components (especially components/schemas) holds shared objects, referenced from many endpoints."
  ask "The server base URL is http://localhost:8080 and one path is /orders. What full URL does a client call to create an order?" \
    "http://localhost:8080/orders" \
    "Just /orders — the base URL is only there for documentation" \
    "http://localhost:8080, with the path passed as a header" \
    "localhost/orders, without the port" \
    1 \
    "The full endpoint URL is the server base URL + the path: http://localhost:8080 + /orders = http://localhost:8080/orders."
}
