# shellcheck shell=bash disable=SC2034
TASK_TITLE="Pull a field with jq"
TASK_CAT="HTTP with curl"
TASK_BODY="You've used 'jq .' to pretty-print and validate JSON. Its real power is
SELECTING — pulling out exactly the value you want. Pipe a live response straight
into it:
  curl -s http://localhost:8080/contacts | jq .              # pretty-print it all
  curl -s http://localhost:8080/contacts/3 | jq -r .lastName   # just one field
(-r gives 'raw' output — no surrounding quotes.)

Notice the '-s' flag on curl: without it, curl prints a download progress meter
alongside the JSON, and that meter gets mixed into the terminal when you pipe —
ugly and confusing. With '-s', only the JSON reaches jq, and only the field you
asked for appears on screen. Get in the habit: when curl's output goes anywhere
other than straight to your terminal (a pipe, a file redirect, another command),
use '-s' to keep things clean.

Now: fetch contact number 3, pull out just its last name with jq, and save that
into a file named lastname.txt."
TASK_TRY="curl -s http://localhost:8080/contacts/3 | jq -r .lastName"
TASK_WHY="jq turns 'a blob of JSON' into 'the one value I need,' which is how you
script against APIs and sanity-check responses. .field drills in; .[] loops an
array; .[0].name grabs the first item's name."
TASK_GOAL="Save contact 3's last name into lastname.txt"
TASK_HINTS=(
  "Pipe the contact into jq and select .lastName, saving it: ... | jq -r .lastName > lastname.txt"
  "Contact 3 is Grace Hopper, so lastname.txt should contain Hopper."
  "Run it without -s first to see the meter noise, then add -s to see only the data."
)
check() {
  if file_contains "$HOME/playground/lastname.txt" "^Hopper$"; then
    pass "jq pulled the last name straight out of the JSON. That's how you consume an API's data."
  else
    fail "extract contact 3's last name with jq into lastname.txt (it should be Hopper)"
    return 1
  fi
}
