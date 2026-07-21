# Module 5 — APIs, contracts & the client/server boundary

**Objective:** Own the contract between systems and the trust boundary between client and server.
You'll author an OpenAPI contract, then take a deliberately-flawed orders API and make it conform —
validating input, returning honest status codes, making writes idempotent, and (the heart of the
module) refusing to trust the client for anything that matters: price, status, and ownership.

**Why this is the heavy one.** This is the first module where the backend is the star. Per the
course thesis, the frontend is where AI shines and mistakes are cheap; the backend is where a subtle
flaw silently corrupts data or leaks it. So here you don't just consume an API — you *own* it. The
AI can write handlers; your senior job is to design the contract, decide the trust rules, and
**prove** the result against hostile input.

---

## How this works: a container + a mounted workspace + two terminals

Same disposable-container idea as Modules 1–4, with one new twist: this module **mounts a local
`workspace/` folder** into the container so you can edit server code from your host — with your
editor and your AI — while the lesson runs inside.

- A flawed **orders API** runs at **http://localhost:8080** (curl it to see the bugs).
- You **own the contract**: `workspace/orders-api.yaml` (OpenAPI 3.0).
- You **harden the server** by editing small handler files in `workspace/handlers/`, and build the
  capstone in `workspace/capstone/`.
- **Your code lives in `workspace/` on your host** — it persists even after the throwaway container
  exits.

### Step 1 — Install Docker (required)
If you did Modules 1–4 you already have it. Otherwise `./sandbox` prints tailored instructions;
in short: macOS → Docker Desktop (or `brew install --cask docker`); Linux →
`sudo apt-get install docker.io` then `sudo systemctl start docker`; Windows → Docker Desktop
(WSL2 backend), run `./sandbox` from a WSL2 shell.

### Step 2 — Enter the sandbox
```
./sandbox
```
This maps ports 8080/8081 and mounts `./workspace` into the container.

### Step 3 — Work in two terminals
This is the modern loop: **direct the AI, then verify.**

- **Terminal A — the container** (opened by `./sandbox`): run the guide and probe the API.
  ```
  lesson next     # what to do next
  lesson check    # verify your work (or answer its question); on success, advance
  lesson hint     # a nudge
  lesson map      # all tasks
  lesson jump N   # jump to task N
  lesson reset    # start over
  ```
- **Terminal B — your host, in `workspace/`**: open your editor / point your AI at the file the task
  names (e.g. `workspace/handlers/12-price.py`) and the contract. Edits appear in the container
  instantly.

Then back in Terminal A, `lesson check` fires a battery of real requests at your handler — good
input, bad input, forged fields, retries — and tells you exactly which behaviors pass. The AI never
runs in the container; the mounted folder is the bridge.

> Tasks are independent — `lesson jump` anywhere. Each hardening drill seeds its own starter file, so
> your fixes don't need to accumulate. The capstone is where it all comes together.

---

## The mental model

### The server is the last line of defense
Every request flows through the server: **parse → authenticate (who are you?) → authorize (may you?)
→ validate → do the work → respond.** The client — a browser, a mobile app, curl, or a hostile
script — can send *anything*. Any check that lives only in the frontend can be bypassed by calling
the API directly. So the rules that matter live on the server.

### Never trust the client
The single most expensive class of API bug is trusting client-supplied authoritative data. In this
module you *exploit then harden* three versions of it:
- **Price** — the client sends `totalCents: 1` for a $12 item. Fix: the server computes the total
  from its own catalog and ignores the client's number.
- **Status** — the client sends `status: "paid"` without paying. Fix: the server controls the
  lifecycle; a new order is always `pending`.
- **Ownership** — Alice reads Bob's order. Fix: authorization — only the owner may read it, else 404.

### Idempotency makes retries safe
A network timeout leaves a client unsure whether its write landed, so it **retries**. A plain `POST`
isn't safe to retry — it creates a second order. Add an **`Idempotency-Key`**: on a repeat key the
server returns the *same* order. `GET`/`PUT`/`DELETE` are naturally idempotent; `POST` isn't until
you make it so. Failure handling and idempotency are two halves of one idea.

### Honest status codes & a contract you own
| Code | Meaning |
|---|---|
| 200 / 201 / 204 | OK / Created / No Content |
| 400 | bad request (validation failed) |
| 401 / 403 | no valid credentials / authenticated but not allowed |
| 404 | not found (also: hiding someone else's resource) |
| 409 | conflict with current state |

The contract (`orders-api.yaml`) is a **first-class artifact you design before code** and defend
after. You'll author new error cases and a new endpoint into it. Also covered: **pagination** (never
return the whole table), **versioning** (ship `/v2` without breaking `/v1`), and **real-time**
(polling vs. websockets, and what websockets *don't* guarantee).

---

## The demo users & tokens
Writes need `Authorization: Bearer <token>`; reading an order requires you to own it.

| Token | User |
|---|---|
| `alice-token` | alice (owns order 1) |
| `bob-token` | bob (owns order 2) |

## Command cheat-sheet
| Goal | Command |
|---|---|
| List products (public) | `curl -s localhost:8080/products \| jq` |
| Create an order | `curl -s -X POST localhost:8080/orders -H 'Authorization: Bearer alice-token' -d '{"items":[{"productId":1,"qty":2}]}'` |
| See status + headers | add `-i` to any curl |
| Idempotent create | add `-H 'Idempotency-Key: abc123'` |
| List your orders (paged) | `curl -s 'localhost:8080/orders?limit=2&offset=0' -H 'Authorization: Bearer alice-token'` |
| Watch pushes (websocket) | `python3 ~/workspace/ws-listen.py` |
| Validate the contract | `python3 -c 'import yaml;yaml.safe_load(open("orders-api.yaml"))'` |

---

## The capstone
Design and build one new write path — **`POST /orders/{id}/refund`** — end to end: add it to the
contract, then implement `workspace/capstone/refund.py` so it is **owner-only**, **priced by the
server** (never a client-supplied amount), **idempotent**, and **honest with status codes**. Direct
your AI from the contract if you like — then `lesson check` runs the full conformance battery,
including the hostile cases. Passing that battery is the deliverable: you owned the contract and
proved the code.

## Quiz
Two self-grading quizzes (open in a browser; on a Mac from this directory):
```
open quizzes/module-5-quiz.html
```
Then the harder one — it reaches past this module into real-world API design (PATCH vs PUT, 409/422,
rate limiting, CORS, JWT/expiry, optimistic concurrency, cursor pagination, HTTPS):
```
open quizzes/module-5-quiz-advanced.html
```

## What's next
You can now design a contract, defend a trust boundary, and prove an endpoint correct against hostile
input. Module 6 goes underneath the API to **data modeling & integrity** — where the same "own it
deeply, verify it hard" discipline meets the database.
