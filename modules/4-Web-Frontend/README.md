# Module 4 — The web & frontend: consume & verify

**Objective:** Become fluent at *consuming and verifying* the web, not hand-building it. Drive
a real HTTP API from the terminal with `curl` and `jq`, read and write JSON, read an OpenAPI
contract, understand what actually crosses the wire (request line, headers, the `\r\n\r\n` gap,
status codes), and use the browser's DevTools as ground truth. Then the capstone: **vibe-code a
frontend from the spec and prove it works** by reading the backend's access log.

**Why "consume & verify" instead of "build"?** The frontend is exactly where AI coding shines —
so the durable skill isn't hand-writing components, it's *directing* the build with a precise
contract and *checking* the result. That means being able to read the HTTP an app makes, spot the
states it forgot (loading, empty, and especially error), and tell whether the frontend is really
talking to the backend. You'll finish able to judge any AI-built UI, not just admire the screenshot.

---

## How this works: a throwaway container + a live API

Same setup as Modules 1–3: a **disposable Docker container** and a guide called **`lesson`**. What's
new here is that the container also **runs a real API** — a small *contacts* service (first name,
last name, phone, full CRUD) — on **port 8080**, mapped out to your own machine so you can hit it
from both the terminal *and* your browser's DevTools.

- The API lives at **http://localhost:8080**. Reads are public; writes (POST/PUT/DELETE) require a
  bearer token, `let-me-in`.
- Its contract is **`contacts-api.yaml`** (OpenAPI 3.0) in your `~/playground` — the single source
  of truth for every endpoint. It's the file you hand your AI in the capstone.
- A tiny read-only demo UI is served at the root so you have something to inspect in DevTools.

Each task is independent (`lesson jump` anywhere); the check inspects the real result — a file you
saved, the API's actual state, or an answer to a multiple-choice question.

### Step 1 — Install Docker (required)

If you did Modules 1–3 you already have it. Otherwise `./sandbox` prints tailored instructions; in
short: macOS → Docker Desktop (or `brew install --cask docker`); Linux →
`sudo apt-get install docker.io` then `sudo systemctl start docker`; Windows → Docker Desktop
(WSL2 backend), run `./sandbox` from a WSL2 shell.

### Step 2 — Enter the sandbox

```
./sandbox
```

This maps port 8080 out of the container. Leave it running and, in your **own browser**, open
**http://localhost:8080** — that's the same API you're calling with `curl`, ready for DevTools.

### Step 3 — Follow the guide

```
lesson next     # show the next task
lesson check    # verify your work (or answer its question); on success, advance
lesson hint     # a nudge (ask again for the exact command)
lesson map      # see all tasks
lesson jump N   # jump to task N
lesson reset    # start over
exit            # leave the container (it self-destructs)
```

Two kinds of task: **do-something** tasks look for a real result (a file you saved, a contact you
created), with the concrete deliverable shown on the **▸ GOAL** line; **question** tasks have
`lesson check` ask you a multiple-choice question about what you just observed.

---

## The mental model

### An HTTP call is one request and one response

When you run `curl http://localhost:8080/contacts`, you open a connection to a **host** (`localhost`)
on a **port** (`8080`) and ask for a **path** — `/contacts`, an **endpoint**. Every HTTP message has
the same shape:

```
GET /contacts HTTP/1.1        <- request line (method · endpoint · version)
Host: localhost:8080          <- headers (metadata)
Accept: */*
                              <- a BLANK LINE (a bare \r\n\r\n) ends the headers
(optional body)
```

The response comes back the same way: a **status line** (`HTTP/1.0 200 OK`), headers, a blank line,
then the body. `curl -v` shows both sides; `curl -i` shows the response with its headers; and
`curl -i URL | cat -A` reveals the real bytes — each header line ends in `^M$` (that's `\r\n`), and
the lone `^M$` line is the header/body separator.

### Methods map to CRUD, statuses report the verdict

| Method | Does | On success |
|---|---|---|
| `GET` | read | 200 OK |
| `POST` | create | 201 Created |
| `PUT` | update (replace) | 200 OK |
| `DELETE` | remove | 204 No Content |

Status families: **2xx** success · **3xx** redirect · **4xx** you got it wrong (400 bad body, 401 no
auth, 404 not found) · **5xx** the server broke. The status code is the first thing to check when
something's off.

### JSON is the data; YAML is the documented superset

APIs speak **JSON**: objects `{ }` of key/value pairs, arrays `[ ]`, strings (double quotes only),
numbers, booleans, `null` — with **no trailing commas and no comments**. `jq` parses it and selects
values (`jq -r .lastName`). The contract is **YAML**, a *superset* of JSON that adds the one thing
JSON can't do: **comments**, so a spec can document itself.

### Client vs. server, and verification

The demo UI is **client-rendered**: the server sends an almost-empty HTML shell and the browser's
JavaScript fetches `/contacts` and builds the DOM. So *View Source* looks empty while the *Elements*
panel is full — and the **Network tab** is where you see the real requests an app makes. That's how
you verify: don't trust the render, watch the HTTP.

---

## Command cheat-sheet

| Goal | Command |
|---|---|
| Fetch a URL (like a browser) | `curl http://localhost:8080/contacts` |
| Save the response to a file | `curl http://localhost:8080/contacts > contacts.json` |
| See the response status + headers | `curl -i http://localhost:8080/contacts` |
| See BOTH request and response | `curl -v http://localhost:8080/contacts` |
| Reveal the raw `\r\n\r\n` bytes | `curl -i http://localhost:8080/contacts \| cat -A` |
| Follow a redirect | `curl -L http://localhost:8080/old-contacts` |
| Pretty-print / validate JSON | `curl … \| jq .`   ·   `jq . file.json` |
| Pull one field | `curl … \| jq -r .lastName` |
| Filter with a query param | `curl 'http://localhost:8080/contacts?q=hop'` |
| Create (needs token) | `curl -X POST …/contacts -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' -d '{…}'` |
| Update | `curl -X PUT …/contacts/1 -H 'Authorization: Bearer let-me-in' -H 'Content-Type: application/json' -d '{…}'` |
| Delete | `curl -X DELETE …/contacts/2 -H 'Authorization: Bearer let-me-in'` |

---

## The capstone: vibe-code a frontend, then prove it

Hand **`contacts-api.yaml`** to your AI and have it build a small contacts UI (a single standalone
HTML file is perfect) that can list, add, edit, and delete against `http://localhost:8080`
(writes carry `Authorization: Bearer let-me-in`; CORS is open). Then open it, *use* it, and run
`lesson check` — it reads the API's access log and confirms your frontend actually exercised
**list + create + update + delete**. Reads alone don't count, and the built-in demo can only GET —
so those writes can only have come from the app *you* directed. That's the whole point: you owned
the contract and the verification.

---

## Quiz

Test yourself with the interactive quiz — it grades itself and explains each answer. Open it in your
browser; on a Mac, from this directory:

```
open quizzes/module-4-quiz.html
```

(Linux: `xdg-open quizzes/module-4-quiz.html`; or double-click it.)

Once that feels easy, try the **advanced quiz** — harder, and it reaches past this module into
real-world HTTP (idempotency, PATCH, CORS preflight, redirects, caching/ETags, rate limiting, TLS,
auth schemes, statelessness). Anything you miss is worth knowing the next time you consume an API:

```
open quizzes/module-4-quiz-advanced.html
```

## What's next

You can now read, drive, and verify an HTTP API by hand, and judge an AI-built frontend by the HTTP
it makes rather than by how it looks. From here the course moves into building and deploying real
services — where the same contract-and-verify discipline is what keeps AI-assisted work honest.
