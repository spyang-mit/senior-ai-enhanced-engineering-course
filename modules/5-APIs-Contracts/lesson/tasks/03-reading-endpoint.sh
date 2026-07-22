# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the contract: an endpoint"
TASK_CAT="Contract-first"
TASK_BODY="Put the pieces together on one operation. Find POST /orders under
paths: and read its parts:
  security:     [{ bearerAuth: [] }]   — this call needs a bearer token
  requestBody:  references NewOrder    — the typed JSON you SEND
  responses:    201 -> Order, plus 400, 401 (and the 409 you'll add) — the typed
                JSON you GET back, per status code

That security line has TWO brackets, two meanings:
  security: [ ... ]      the OUTER list is your auth OPTIONS — any one satisfies it
  { bearerAuth: [] }     one option: a map of scheme name -> its required SCOPES
  bearerAuth: []         the inner [] is that scope list. Bearer auth has no
                         scopes, so it's empty — but the spec still requires the
                         array. (OAuth2 would list scopes here, e.g. [orders:read].)

That's the whole value of a typed contract: the request shape, the response
shape, the auth, and every possible status are all written down. A client
developer can build and test against this WITHOUT ever seeing the server — and
the server must honor exactly what's written. Read POST /orders and GET
/orders/{id}, then run 'lesson check'."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="An endpoint definition is a contract in miniature: inputs, outputs,
auth, and failure modes. Reading one fluently is what lets you implement it,
call it, or review an AI's version of it with confidence."
TASK_HINTS=(
  "Under paths: -> /orders: -> post:, read the security, requestBody, and responses keys in turn."
  "Match each response code to the schema it returns (201 -> Order, 400/401 -> Error)."
)
setup() { seed_contract; }
quiz() {
  ask "Under POST /orders you see  security: [{ bearerAuth: [] }].  That means…" \
    "this endpoint is completely public, no token needed" \
    "this endpoint requires a bearer token" \
    "the responses will be encrypted" \
    "only GET requests are allowed here" \
    2 \
    "security ties the operation to the bearerAuth scheme in components — a valid token is required to call it."
  ask "requestBody references NewOrder and the 201 response references Order. What does that give a client developer?" \
    "Nothing genuinely useful until they read the server's code" \
    "A fully rendered HTML form for the endpoint" \
    "The exact JSON to send and to expect back, without seeing the server" \
    "A direct copy of the server's source code" \
    3 \
    "Typed request + response schemas ARE the interface — you can build and test a client purely from the contract."
  ask "The responses block lists 201, 400, 401 (and the 409 you'll add). Why enumerate every status a caller might get?" \
    "So the client knows each outcome and can handle it" \
    "To make the file longer" \
    "Because YAML requires exactly three responses" \
    "They are only documentation and are ignored by the server at runtime" \
    1 \
    "Each declared status is a promise. The client codes for all of them — success, validation error, auth failure — instead of guessing."
  ask "Overall, what makes a strongly-typed contract like this so valuable?" \
    "It guarantees the server code contains no bugs whatsoever" \
    "It removes the need for any authentication" \
    "It makes the API respond faster" \
    "Client and server teams can build in parallel against one agreed interface" \
    4 \
    "One typed interface both sides commit to is the core reason contracts exist: build independently, integrate with confidence."
  ask "In  security: [{ bearerAuth: [] }],  what is the empty list [] after bearerAuth?" \
    "A meaningless placeholder that has no effect and can be deleted" \
    "The list of scopes required — empty because bearer auth has none" \
    "A list of the users allowed to call this endpoint" \
    "The list of HTTP methods the token is permitted to use" \
    2 \
    "A scheme maps to its required SCOPES. Bearer auth has no scopes, so the list is empty (the spec still requires the array). OAuth2 would list scopes there, like [orders:read]."
}
