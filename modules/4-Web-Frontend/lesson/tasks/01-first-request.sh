# shellcheck shell=bash disable=SC2034
TASK_TITLE="Visit a URL, two ways"
TASK_CAT="HTTP basics"
TASK_BODY="The web runs on HTTP: a CLIENT asks a SERVER for something (a REQUEST)
and the server answers (a RESPONSE). Your browser is a client. So is 'curl' — a
tool that does the same thing from the terminal, showing you the raw answer with
no window in the way.

First, decode the address you'll use — http://localhost:8080/contacts :
  http://     the protocol — how client and server talk (HTTP)
  localhost   THIS machine; the name always means 'right here on this computer'
  :8080       the PORT — which program to talk to. One machine runs many
              services at once, and the port number picks the right 'door.'
              Our contacts API is listening on port 8080.
  /contacts   the PATH — which resource you're asking for.

Just VISITING a URL performs an HTTP GET — 'give me this.' (GET is one of a few
verbs; you'll meet POST, PUT, and DELETE soon.)

Do it both ways and watch them match:
  1. In your browser, open   http://localhost:8080/contacts
     — you'll see the raw JSON the server sends back.
  2. In this terminal, run   curl -s http://localhost:8080/contacts
     — the very same JSON. curl is just a browser without the chrome.
  The '-s' flag means 'silent' — curl won't print its download progress meter, so
  the terminal output stays clean. You'll see why that matters as soon as you pipe
  curl into another tool.

Then save that response into a file named contacts.json (redirect curl's output
the same way you saved command output back in Module 1)."
TASK_TRY="curl -s http://localhost:8080/contacts"
TASK_WHY="Seeing identical JSON in the browser and in curl is the whole point: a
browser is just a fancy HTTP client. Once you can drive HTTP from the terminal,
you can inspect any API directly — no app, no guessing about what it returns."
TASK_GOAL="Save the contacts list to contacts.json"
TASK_HINTS=(
  "Open http://localhost:8080/contacts in your browser first, then run the same URL through curl."
  "Save it to a file: curl -s http://localhost:8080/contacts > contacts.json"
)
check() {
  local f="$HOME/playground/contacts.json"
  if [ -f "$f" ] && jq -e 'type=="array"' "$f" >/dev/null 2>&1 && file_contains "$f" "Lovelace"; then
    pass "same JSON in the browser and in curl — you've made an HTTP GET request and saved the response."
  else
    fail "save the contacts list to a file: curl -s http://localhost:8080/contacts > contacts.json"
    return 1
  fi
}
