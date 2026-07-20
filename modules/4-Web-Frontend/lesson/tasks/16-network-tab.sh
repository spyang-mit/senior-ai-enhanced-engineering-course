# shellcheck shell=bash disable=SC2034
TASK_TITLE="The Network tab is ground truth"
TASK_CAT="In the browser"
TASK_BODY="Now switch from the terminal to a real browser. The same API is at
http://localhost:8080 — open that on your OWN machine.

Open DevTools (F12, or Cmd-Option-I on a Mac) and click the NETWORK tab. Reload
the page and watch: the little contacts app makes a request to /contacts and
gets back a response — the exact same exchange you did with curl. Click that
request to inspect its method, status, headers, and response.

Look at the status shown for that GET /contacts request, then run 'lesson check'."
TASK_TRY="curl -s -i http://localhost:8080/contacts"
TASK_WHY="When an AI-built UI breaks, the Network tab tells you instantly whether
the frontend or the backend is at fault: did the request even go out? what
status came back? what was the payload? The Network tab and curl are two windows
onto the same HTTP — trust them over the rendered page."
TASK_HINTS=(
  "In the Network tab, click the /contacts request and read its Status column — it's the same code curl showed you."
  "The list loads fine, so the request succeeded: a 2xx."
)
TASK_QUIZ="In the Network tab, what status does the successful GET /contacts show?"
TASK_QUIZ_OPTIONS=("200" "301" "404" "500")
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="200 OK — what the Network tab shows and what curl reports are the same HTTP exchange. That's your ground truth."
