# shellcheck shell=bash disable=SC2034
TASK_TITLE="Write valid JSON (the rules)"
TASK_CAT="JSON"
TASK_BODY="Reading JSON is half of it; you also have to WRITE it — every POST or
PUT body you send is JSON. The syntax is strict, and these rules are exactly
where people get burned:
  • keys and strings use DOUBLE quotes  \"like this\"  — never single quotes
  • separate pairs and items with commas, but NO comma after the last one
  • numbers and true / false / null take no quotes
  • comments are NOT allowed — none, ever

By hand, write a single contact as a JSON OBJECT into a file named new.json,
with three string fields: firstName, lastName, and phone. Then prove it's valid
by pretty-printing it:
  jq . new.json      # prints it back = valid.  shows an error = you broke a rule

When 'jq . new.json' echoes your object cleanly, run 'lesson check'."
TASK_TRY="jq . new.json"
TASK_WHY="A stray single quote or a trailing comma is the #1 reason an API
rejects a request or a config file won't load. 'jq . file' is your instant
validator — reach for it. You'll reuse this exact JSON shape when you POST a new
contact in a few tasks."
TASK_GOAL="Write a valid JSON object with firstName, lastName, and phone into new.json"
TASK_HINTS=(
  "Create the file with an editor, or a heredoc: cat > new.json  then type the object, then a line with only  EOF ... actually use  vi new.json  if you prefer."
  'A valid object looks like: {"firstName":"Grace","lastName":"Hopper","phone":"555-0100"} — double quotes everywhere, no trailing comma.'
)
check() {
  local f="$HOME/playground/new.json"
  if [ ! -f "$f" ]; then
    fail "create new.json — a JSON object with firstName, lastName, and phone (validate with: jq . new.json)"
    return 1
  fi
  if ! jq -e '
      type=="object"
      and (.firstName|type=="string")
      and (.lastName |type=="string")
      and (.phone    |type=="string")' "$f" >/dev/null 2>&1; then
    fail "new.json must be a valid JSON object with STRING firstName, lastName, and phone. Check it with: jq . new.json"
    return 1
  fi
  pass "valid JSON — three string fields, correct quoting, no stray commas. That's a POST body ready to send."
}
