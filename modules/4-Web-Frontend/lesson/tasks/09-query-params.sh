# shellcheck shell=bash disable=SC2034
TASK_TITLE="Filter with a query parameter"
TASK_CAT="HTTP with curl"
TASK_BODY="A URL can carry QUERY PARAMETERS after a '?' to customize a request —
here, to filter the list. The contract says GET /contacts takes an optional 'q'.
Search for contacts whose name contains 'hop':
  curl -s 'http://localhost:8080/contacts?q=hop'
(Quote the whole URL so your shell doesn't treat the ? or & specially.)

Now: search for 'hop', pull the single match's last name with jq, and save it
into a file named match.txt."
TASK_TRY="curl -s 'http://localhost:8080/contacts?q=hop'"
TASK_WHY="Query params are how clients ask for a subset — search, filters,
pagination (?page=2&limit=20). Same endpoint, different results, driven entirely
by the URL. A search box in a UI is just this under the hood."
TASK_GOAL="Save the matched contact's last name into match.txt"
TASK_HINTS=(
  "Quote the whole URL, then pull the first result's last name: ... | jq -r '.[0].lastName' > match.txt"
  "'hop' matches Grace Hopper, so match.txt should contain Hopper."
)
check() {
  if file_contains "$HOME/playground/match.txt" "^Hopper$"; then
    pass "the ?q= filter narrowed the list server-side — that's a search box's backend in one URL."
  else
    fail "filter with ?q=hop and save the match's last name to match.txt (Hopper)"
    return 1
  fi
}
