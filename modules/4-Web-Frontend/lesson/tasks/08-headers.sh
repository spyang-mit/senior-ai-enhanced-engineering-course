# shellcheck shell=bash disable=SC2034
TASK_TITLE="Headers & content type"
TASK_CAT="HTTP with curl"
TASK_BODY="Alongside the body, every response carries HEADERS — key: value
metadata about the response. You already saw them: 'curl -i' prints the status
line and all the headers before the body.
  curl -s -i http://localhost:8080/contacts

Find the 'Content-Type' header. It tells the client how to READ the body. Look
at its value, then run 'lesson check'."
TASK_TRY="curl -s -i http://localhost:8080/contacts"
TASK_WHY="Content-Type is how a browser or client decides to parse JSON vs.
render HTML vs. show an image. A wrong or missing content type is a classic
'why won't this parse?' bug. Headers also carry auth, caching, and CORS info —
they're the metadata layer of every request and response."
TASK_HINTS=(
  "In the 'curl -s -i' output, find the line beginning 'Content-Type:' and read its value."
  "The body is JSON, so the type is the one that names JSON."
)
TASK_QUIZ="What Content-Type does GET /contacts report?"
TASK_QUIZ_OPTIONS=("application/json" "text/html" "text/plain" "application/xml")
TASK_QUIZ_ANSWER=1
TASK_QUIZ_EXPLAIN="application/json — that's how a client knows to parse the body as JSON."
