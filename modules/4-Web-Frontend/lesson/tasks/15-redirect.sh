# shellcheck shell=bash disable=SC2034
TASK_TITLE="Follow a redirect (3xx)"
TASK_CAT="HTTP with curl"
TASK_BODY="A 3xx status means 'what you want is somewhere else' — the response
carries a 'Location' header pointing at the new URL. This API has an old path,
/old-contacts, that redirects to /contacts.

See the redirect with -i — note the status line and the Location header:
  curl -s -i http://localhost:8080/old-contacts

By default curl (and curl-in-a-terminal) does NOT follow it — you just see the
3xx. Add -L to follow the Location automatically, the way a browser does:
  curl -s -L http://localhost:8080/old-contacts        # ends up at the real list

Look at the redirect's own status code (the 3xx, not the final 200), then run
'lesson check'."
TASK_TRY="curl -s -i http://localhost:8080/old-contacts"
TASK_WHY="Redirects power moved pages, http→https upgrades, and trailing-slash
fixes. Knowing that a plain request STOPS at the 3xx (while browsers and 'curl
-L' follow it) explains a lot of 'my request got an empty/weird response.'"
TASK_HINTS=(
  "curl -s -i shows the redirect's own status first, plus a Location header — before you follow it with -L."
  "It's the classic 'moved permanently' redirect — a 3xx code."
)
TASK_QUIZ="What status does GET /old-contacts itself return (before you follow it)?"
TASK_QUIZ_OPTIONS=("200" "301" "404" "500")
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="301 Moved Permanently, with a Location header. 'curl -L' (and every browser) follows it to /contacts."
