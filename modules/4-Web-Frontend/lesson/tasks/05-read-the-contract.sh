# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the contract (OpenAPI)"
TASK_CAT="HTTP with curl"
TASK_BODY="Before calling an API, you read its CONTRACT — the document that says
what endpoints exist, what to send, and what comes back. The standard format is
OpenAPI (a YAML or JSON file). This API's contract is right here:
  less contacts-api.yaml        (q to quit)   — or:  cat contacts-api.yaml

Skim it. Notice how each path (like /contacts) lists the METHODS it supports.
HTTP has a small set of verbs, and they map to the four things you do with data
(often called CRUD):
  GET     read      (fetch a contact or the list)
  POST    create    (add a new contact)
  PUT     update    (replace an existing contact)
  DELETE  remove    (delete a contact)
The contract says which verbs each path allows, what each returns, and which
ones need auth. You'll practice all four in the tasks ahead.

When you've found how a new contact gets created, run 'lesson check' to answer."
TASK_TRY="less contacts-api.yaml"
TASK_WHY="The contract is how you (and your AI) know which endpoints to hit
without guessing. Reading one fluently is a real skill — and it's exactly what
you'll hand your AI when you build a frontend later in this module."
TASK_HINTS=(
  "Look under 'paths: /contacts:'. GET fetches the list; another verb on the same path ADDS a new one."
  "Creating a resource — adding a brand-new one — is done with POST."
)
TASK_QUIZ="Per the contract, which HTTP method creates a new contact?"
TASK_QUIZ_OPTIONS=("GET" "PUT" "POST" "DELETE")
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="POST creates. GET reads, PUT updates, DELETE removes — that's CRUD."
