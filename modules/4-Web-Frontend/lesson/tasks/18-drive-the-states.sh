# shellcheck shell=bash disable=SC2034
TASK_TITLE="Drive every state (and find the gap)"
TASK_CAT="In the browser"
TASK_BODY="Verifying a UI means DRIVING it — pushing it through every state, not
just glancing at the happy path. A data-driven view generally has four:
  loading · success · empty · error
In the app at http://localhost:8080, trigger each one and watch what it does:
  • Type 'zzzz' in the search box  -> EMPTY  (it says 'No contacts found')
  • Click 'Reload (slow)'          -> LOADING (it says 'Loading…' for a bit)
  • Clear the search / Reload      -> SUCCESS (the table)
  • Click 'Simulate server error'  -> ??? watch carefully. Open the Console too.

That last one hits an endpoint that returns 500. Watch what the app does with
it, then run 'lesson check'."
TASK_TRY="open http://localhost:8080 and click every button"
TASK_WHY="This is the module's core skill. AI-built UIs nail the happy path and
routinely forget loading, empty, and especially ERROR states. 'It rendered' is
not 'it works' — you only find the gaps by driving every state yourself."
TASK_HINTS=(
  "Loading, empty, and success all display something sensible. One button breaks the page with a blank screen and a Console exception."
  "The 500 case is handled by nothing — there's no state for when the request fails."
)
TASK_QUIZ="Which of the four states does this app FAIL to handle?"
TASK_QUIZ_OPTIONS=("loading" "success" "empty" "error")
TASK_QUIZ_ANSWER=4
TASK_QUIZ_EXPLAIN="No error state — the 500 blanks the page. Driving the app catches that; a happy-path screenshot never would."
