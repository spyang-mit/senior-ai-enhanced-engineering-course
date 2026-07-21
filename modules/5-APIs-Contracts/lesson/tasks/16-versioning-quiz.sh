# shellcheck shell=bash disable=SC2034
TASK_TITLE="API versioning strategy"
TASK_CAT="Scale & failure semantics"
TASK_BODY="APIs change over time. A breaking change to an endpoint (e.g. changing
a field name, removing an endpoint) would break every existing client. Versioning
is how you evolve without breaking your consumers.

Two common approaches:
  • URL-prefix versioning:  /v1/orders   vs   /v2/orders
  • Header versioning:      Accept: version=1   vs   Accept: version=2

Each has trade-offs. URL versioning makes it obvious which version is in use
(you see it in the URL). Header versioning keeps URLs clean but requires every
client to send the right header — and a client that sends no header is ambiguous.

Read the contract again — the current API has no version prefix. Then answer."
TASK_WHY="Versioning is a contract-first concern: you decide how to version BEFORE
you ship v2, because changing the scheme later means every client changes too."
TASK_HINTS=(
  "URL-prefix: /v1/orders/1 — simple, visible, cache-friendly."
  "Header: Accept: application/vnd.orders.v1+json — cleaner URLs but requires client cooperation."
)
TASK_QUIZ="Why is URL-prefix versioning (/v1/...) generally preferred for new APIs?"
TASK_QUIZ_OPTIONS=(
  "It's the only standard — HTTP defines no other way to version"
  "It's visible in every request, cache-friendly, and doesn't require client header logic"
  "It prevents all breaking changes forever"
  "It's required by OpenAPI spec"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="URL-prefix versioning (/v1/orders) is visible, cache-friendly, and works even with clients that send no custom headers. Header versioning is more elegant but requires every client to send the right Accept header — and 'no header' is ambiguous."
