# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read a component for gaps"
TASK_CAT="Judging the UI"
TASK_BODY="You don't have to WRITE React to judge it — you have to READ it. An AI
dropped a component in your playground: component.jsx. Open it:
  cat component.jsx        (or: less component.jsx)

Read what it does. It fetches the contacts on mount, shows 'Loading…' while the
request is in flight, and shows an error message if the request fails. So it
handles loading and error.

Now think like a verifier: what does the user SEE when the API returns an empty
list ([])? Trace the code, then run 'lesson check'."
TASK_TRY="cat component.jsx"
TASK_WHY="Reading a component for MISSING states is the whole 'reading depth' you
need for AI frontends. Loading and error are here; but an empty list renders a
bare <ul> with no 'no contacts yet' message — a blank void the user won't
understand. That empty-state gap is one of the most common AI omissions."
TASK_HINTS=(
  "It explicitly checks loading and error. Follow what renders when 'contacts' is [] — the map produces no rows and nothing else fills the gap."
  "There's no branch for a successful-but-empty result — that's the missing state."
)
TASK_QUIZ="Which state does this component forget to handle?"
TASK_QUIZ_OPTIONS=("loading" "success" "empty" "error")
TASK_QUIZ_ANSWER=3
TASK_QUIZ_EXPLAIN="The empty state — an empty list renders a bare <ul> with no 'no contacts yet' message. A very common AI omission."
setup() {
  local f="$HOME/playground/component.jsx"
  [ -e "$f" ] || cat > "$f" <<'EOF'
import { useState, useEffect } from "react";

// A contact list an AI generated. Read it: which state does it forget?
export function ContactList() {
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("http://localhost:8080/contacts")
      .then((res) => {
        if (!res.ok) throw new Error("request failed");
        return res.json();
      })
      .then((data) => setContacts(data))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading…</p>;
  if (error) return <p>Something went wrong: {error}</p>;

  return (
    <ul>
      {contacts.map((c) => (
        <li key={c.id}>
          {c.firstName} {c.lastName} — {c.phone}
        </li>
      ))}
    </ul>
  );
}
EOF
}
