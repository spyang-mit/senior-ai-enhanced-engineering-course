# shellcheck shell=bash disable=SC2034
TASK_TITLE="YAML: JSON with room to breathe"
TASK_CAT="The contract"
TASK_BODY="You've been reading contacts-api.yaml — the API contract — all module.
It's written in YAML, and here's the useful truth: YAML is a SUPERSET of JSON.
Every JSON document is already valid YAML, but YAML adds a friendlier syntax on
top:
  • indentation instead of { } and [ ]
  • quotes optional on most strings
  • and the big one: COMMENTS. Any line starting with # is documentation.

That last point matters. JSON forbids comments, so a pure-JSON contract can't
explain itself. YAML can — which is why OpenAPI specs, CI pipelines, and
Kubernetes configs are written in YAML: the file documents its own intent, right
next to the data.

Open the contract and notice the '#' comment banners and the 'description:'
text explaining each field and endpoint — documentation you simply cannot put in
raw JSON:
  less contacts-api.yaml

When you see why the contract is YAML and not JSON, run 'lesson check'."
TASK_TRY="less contacts-api.yaml"
TASK_WHY="You'll hand this YAML contract to your AI to build a frontend. A format
that carries human-readable documentation alongside the data is what makes a
spec a usable contract — and knowing JSON is a subset of YAML means you can read
and write both with one mental model."
TASK_HINTS=(
  "The data model is the same as JSON — objects and lists — but scan for lines the machine ignores that are there purely for humans."
  "The standout thing YAML allows and JSON forbids is inline comments / documentation (the # lines)."
)
TASK_QUIZ="What can YAML do that plain JSON cannot?"
TASK_QUIZ_OPTIONS=(
  "Store ordered lists and key/value mappings"
  "Be parsed automatically by a computer"
  "Carry inline comments and documentation"
  "Represent both numbers and text strings"
)
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="YAML allows # comments and docs; JSON forbids them. Both store lists, mappings, numbers, and text — YAML is a superset of JSON."
