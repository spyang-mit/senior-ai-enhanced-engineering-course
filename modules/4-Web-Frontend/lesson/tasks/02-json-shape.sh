# shellcheck shell=bash disable=SC2034
TASK_TITLE="JSON: the shape of data"
TASK_CAT="JSON"
TASK_BODY="That response you just saved is JSON (JavaScript Object Notation) — the
format almost every web API speaks. It's worth knowing cold. JSON is built from
just a few pieces:

  object   { ... }   a set of KEY: VALUE pairs; keys are strings in \"quotes\"
  array    [ ... ]   an ORDERED list of values
  string   \"hi\"      text, always in double quotes
  number   42, 3.14  digits, no quotes
  boolean  true / false
  null     an explicit 'no value'

Objects and arrays nest freely — that's how JSON represents anything from a
single contact to a whole list of them.

'jq' is a tool for working with JSON; 'jq .' pretty-prints it with indentation
so the structure is easy to see:
  cat contacts.json | jq .

Study the shape: the whole response is a LIST, and each item in the list is a
contact OBJECT with keys like firstName and phone. When you can see that, run
'lesson check'."
TASK_TRY="cat contacts.json | jq ."
TASK_WHY="Every API response, every config file, every fetch() in a frontend is
JSON. Reading its shape at a glance — 'this is an array of objects, each with
these keys' — is the foundation for everything else in this module."
TASK_HINTS=(
  "The very outermost characters wrap everything else. Are they { } or [ ] ?"
  "The whole thing is wrapped in [ ] — an ordered list — and each element inside is an object { }."
)
TASK_QUIZ="At the top level, the contacts response is which kind of JSON value?"
TASK_QUIZ_OPTIONS=("a single object" "a string" "a number" "an array")
TASK_QUIZ_ANSWER=4
TASK_QUIZ_EXPLAIN="It's an array [ ] — an ordered list — and each element is a contact object { }."
setup() {
  # Make sure contacts.json exists even if the learner jumped straight here.
  [ -f "$HOME/playground/contacts.json" ] || curl -s "$API/contacts" -o "$HOME/playground/contacts.json" 2>/dev/null || true
}
