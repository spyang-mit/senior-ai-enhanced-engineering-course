# shellcheck shell=bash disable=SC2034
TASK_TITLE="Versioning the contract"
TASK_CAT="Scale & failure"
TASK_BODY="Once other people depend on your API, you can't just change it — a
breaking change (renaming a field, tightening a rule) breaks every existing
client at once. The answer is VERSIONING: expose the new, incompatible shape at a
new address (commonly a path prefix like /v1/orders, /v2/orders, or a version in
a header) so old clients keep hitting the version they were built against while
new clients opt into the new one.

Read that, then run 'lesson check' for a question."
TASK_TRY="grep -n 'servers:' ~/workspace/orders-api.yaml"
TASK_WHY="Backward compatibility is a promise. Versioning is how you keep that
promise while still evolving — you add /v2 instead of silently breaking /v1.
It's the difference between shipping a change and causing an outage."
TASK_HINTS=(
  "The point of a version is to let TWO shapes of the API exist at once."
  "So a breaking change can go live as a new version while the old one still serves existing clients."
)
TASK_QUIZ="Why do APIs put a version in the path, like /v1/orders?"
TASK_QUIZ_OPTIONS=(
  "Ship a breaking change as /v2 while /v1 clients keep working"
  "Because browsers strictly require a version segment in every URL path"
  "To make the API's URLs look more professional and clean"
  "So the server can skip auth checks on the older versions"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="Versioning lets an incompatible change ship as /v2 while existing /v1 clients keep working — evolve without breaking anyone."
