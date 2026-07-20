# shellcheck shell=bash disable=SC2034
TASK_TITLE="Client vs. server (where JS runs)"
TASK_CAT="In the browser"
TASK_BODY="Here's the single most important idea about the modern web. In your
browser on http://localhost:8080:

  • Right-click -> 'View Page Source' (or Ctrl-U). This is the raw HTML the
    SERVER sent. Look closely — there are NO contact names in it. It's an empty
    shell.
  • Now open the 'Elements' (DOM) panel — it's a tab inside the Developer
    Tools. In Chrome, click View -> Developer -> Elements, or right-click
    anywhere on the page and choose "Inspect" (ctrl-click on a Mac). The
    table is FULL of contacts.

How? JavaScript running in your BROWSER (the client) fetched /contacts and built
those rows after the page loaded. View-source = what the server sent; the DOM =
what the client made of it. Confirm it from the terminal — the served HTML has
no contact data in it:
  curl -s http://localhost:8080/ | grep -i lovelace     # prints nothing

Then run 'lesson check'."
TASK_TRY="curl -s http://localhost:8080/ | grep -i lovelace"
TASK_WHY="'Client vs. server' explains where code runs, where data lives, and why
you can't trust the client. This app renders on the client (empty shell + JS +
API). Server-rendered apps send the filled HTML instead. Knowing which you're
looking at is step one in judging any frontend."
TASK_HINTS=(
  "View-source (and 'curl -s /') shows the server's HTML — no names. The DOM shows names because JS added them after load."
  "The data isn't in the page the server sends; the browser fetches it separately and builds the DOM."
)
TASK_QUIZ="Where do the contact names in the page come from?"
TASK_QUIZ_OPTIONS=(
  "They're already baked into the HTML the server delivers"
  "The browser's JavaScript fetches them and builds the DOM"
  "They're permanently hard-coded inside the web browser itself"
  "The server re-renders the full page on each keystroke"
)
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN="The server sends an empty shell; the browser's JS fetches /contacts and builds the DOM. That's client-side rendering."
