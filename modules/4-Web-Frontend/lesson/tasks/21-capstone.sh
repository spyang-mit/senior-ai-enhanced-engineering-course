# shellcheck shell=bash disable=SC2034
TASK_TITLE="Capstone: vibe-code a verified frontend"
TASK_CAT="Capstone"
TASK_BODY="Put it all together the modern way: let an AI build the UI while YOU
own the spec and the verification.

You are inside a throwaway container — anything saved here disappears on
exit. So build the frontend OUTSIDE, on your host machine:

  🪵 Keep this container running (do NOT type 'exit').
  🖥️ Open a new terminal window / tab on your host machine.
  🤖 Start an AI session there (Claude Code, Claude.ai, ChatGPT, etc.)
     and paste in the contract file as context.

The contract is contacts-api.yaml. On your host, it's at:
  senior-ai-enhanced-engineering-course/modules/4-Web-Frontend/app/contacts-api.yaml

Paste that into your AI and ask for a small contacts frontend (a single
standalone HTML file is perfect) that can LIST, ADD, EDIT, and DELETE contacts
against http://localhost:8080. Tips to give your agent:
  • The full API is described in contacts-api.yaml — hand it that.
  • Writes (POST/PUT/DELETE) need the header:  Authorization: Bearer let-me-in
  • CORS is open, so you can open your HTML from anywhere and it can call the API.

Save the HTML file on your host (NOT inside this container — it would be lost
when you exit). Then OPEN it in your browser and actually USE it: add a contact,
edit one, and delete one. When you have, come back here and run 'lesson check'.
It reads the API's access log and confirms your frontend really exercised
list + create + update + delete.

(Reads alone don't count, and the built-in demo app can only GET — so these
writes can only come from the app YOU built.)"
TASK_TRY="cat contacts-api.yaml"
TASK_WHY="This is the whole course thesis in miniature: the frontend is where AI
shines, so you direct it with a precise spec and PROVE it works by verification —
here, the backend's own log of which endpoints got hit. You didn't hand-write a
UI; you owned the contract and the check."
TASK_GOAL="Build a frontend that exercises full CRUD against the API"
TASK_HINTS=(
  "Give your AI contacts-api.yaml and ask for a standalone HTML app doing full CRUD against http://localhost:8080, with the Bearer let-me-in header on writes. Open it, then add/edit/delete a contact."
  "Check what's landed so far:  cat ~/.server/access.log  — you need a POST, a PUT, and a DELETE on /contacts, plus a GET."
  "Don't exit the container! Keep it running while you build and test the frontend on your host machine."
)
setup() {
  clear_access_log
}
check() {
  local miss=""
  log_has '^GET /contacts'          || miss="$miss list(GET)"
  log_has '^POST /contacts '        || miss="$miss create(POST)"
  log_has '^PUT /contacts/[0-9]'    || miss="$miss update(PUT)"
  log_has '^DELETE /contacts/[0-9]' || miss="$miss delete(DELETE)"
  if [ -z "$miss" ]; then
    pass "your frontend exercised list, create, update, AND delete against the real API — the access log proves it. You directed the build and verified it end to end. 🎉"
  else
    fail "the access log doesn't show these yet:$miss — build/use them in your app (writes need Authorization: Bearer let-me-in), then run lesson check again."
    return 1
  fi
}
