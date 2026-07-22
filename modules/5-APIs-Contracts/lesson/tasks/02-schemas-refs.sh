# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read the contract: schemas & \$ref"
TASK_CAT="Contract-first"
TASK_BODY="Now the heart of the file: components/schemas. This is where each data
object is defined ONCE — Product, OrderItem, NewOrder, Order, Error — with strong
types (integer, string, array, enum) and a 'required' list.

Anywhere an endpoint needs one of these objects, it writes a reference instead of
repeating the definition:
  \$ref: \"#/components/schemas/Order\"
Define once, reference everywhere — fix the shape in one place and every endpoint
that uses it updates. A few things to notice while you read:
  • Order marks totalCents as 'Computed by the server', and NewOrder (the create
    body) leaves out price/total/status entirely — those are server-owned.
  • OrderItem types qty as 'integer, minimum: 1'.
  • KEYWORDS vs FIELDS. Words like type, properties, items, required, and \$ref
    are schema KEYWORDS: they describe the shape and never appear in the actual
    JSON. The field names you choose (id, userId, items) are your DATA and DO
    appear. Watch Order's 'items' field: the inner 'items:' beneath 'type: array'
    is the array-element KEYWORD (it says what each element looks like) — it just
    happens to be spelled the same as the field above it. Same word, unrelated.

Read the schemas, then run 'lesson check' for a few questions."
TASK_TRY="less ~/workspace/orders-api.yaml"
TASK_WHY="Strong, named types are what let someone write a correct client (or
server) from the contract alone. And \$ref is why a big API stays maintainable:
one definition, many references, no copy-paste drift."
TASK_HINTS=(
  "Find the 'components:' section, then 'schemas:' under it — each object (Order, NewOrder, ...) is defined there."
  "Search the file for \$ref to see the same object reused across endpoints."
)
setup() { seed_contract; }
quiz() {
  ask 'The Order object is defined once in components/schemas. Elsewhere you see  $ref: "#/components/schemas/Order".  What does that do?' \
    "Copies the whole Order definition by hand into that spot each time" \
    "Points to the one Order definition so it is reused, not repeated" \
    "Defines a brand-new, unrelated Order type" \
    "Links out to an external website" \
    2 \
    "A reference reuses the single definition. Change Order once and every endpoint that references it updates."
  ask "OrderItem types qty as 'integer, minimum: 1'. What does that tell a client?" \
    "qty must be a whole number, and at least 1" \
    "qty is optional free-form text" \
    "qty may be any decimal value" \
    "qty is chosen by the server, not the client" \
    1 \
    "Strong typing (integer + minimum:1) tells the client the exact valid shape to send — no need to read server code."
  ask "NewOrder (the create body) lists ONLY items — no price, total, or status. Why?" \
    "Those fields are not needed by anyone" \
    "The client is expected to set each of them in a later follow-up request" \
    "The contract simply forgot to include them" \
    "They are server-authoritative, so the client must not send them" \
    4 \
    "The create payload deliberately omits server-owned fields. The client can't set price/total/status; the server does."
  ask "The Order schema has  required: [id, userId, items, totalCents, status].  What does 'required' mean?" \
    "These fields are optional and may be omitted safely" \
    "These fields are encrypted at rest" \
    "These fields must be present in a valid Order" \
    "These fields are deprecated and unused" \
    3 \
    "required lists the fields that MUST appear; a response missing one does not conform to the contract."
  ask "Order's 'items' field is an array, and under 'type: array' there is a second 'items:'. Why is that inner one also called 'items'?" \
    "It has to match the field name (items) that was declared just above it" \
    "'items' is the JSON Schema keyword for an array's element type" \
    "It is a typo and should be deleted" \
    "It declares a second, separate array" \
    2 \
    "The inner 'items:' is a schema KEYWORD meaning 'the shape of each element' — required whenever type is array. Matching the field name is pure coincidence; rename the field and the keyword stays 'items'."
}
