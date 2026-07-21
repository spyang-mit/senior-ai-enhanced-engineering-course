# shellcheck shell=bash disable=SC2034
TASK_TITLE="The request lifecycle"
TASK_CAT="Validation & codes"
TASK_BODY="Before you harden anything, picture what a request goes through on the
SERVER:
  parse -> authenticate (who are you?) -> authorize (may you?) -> VALIDATE the
  input -> do the work -> respond.
The server is the LAST line of defense. The client — a browser, a mobile app,
curl, or a hostile script — can send absolutely anything. Any check that lives
only in the frontend can be bypassed by talking to the API directly (as you're
about to do with curl).

So input validation is not a UX nicety; it's the boundary that protects your
data. Read that, then run 'lesson check' for a question."
TASK_TRY="curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{}'"
TASK_WHY="Every exploit in this module works by skipping the frontend and hitting
the API. If the server assumes the client already validated, it will happily
store garbage — or worse. 'The server can't trust the client' is the whole
module in one sentence."
TASK_HINTS=(
  "Frontend validation improves the user's experience, but anyone can bypass it with curl."
  "The only validation that actually protects the data is the one the server does itself."
)
TASK_QUIZ="Where must input validation happen to actually protect your data?"
TASK_QUIZ_OPTIONS=(
  "On the server, at the boundary, before it acts"
  "In the browser, before the request is ever sent"
  "Only in the database, through column type constraints"
  "Nowhere — a well-written contract makes it automatic"
)
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="On the server. Client-side checks are bypassable with a direct API call; the server is the last line of defense."
