# Module 5 — APIs, contracts & the client/server boundary

**Objective:** Own the contract between systems and the trust boundary between client and server.
This is where "frontend" stops being cosmetic and becomes an architecture concern. You design the
API contract *first*, then harden the server against exploit after exploit — idempotency,
server-authoritative pricing, authorization, pagination, and a full write-path capstone.

**Why this is heavy (and hands-on).** Module 4 gave you an API to consume. Module 5 flips the
boundary: **you own the contract and the server side.** Per the course thesis, backend is the area
the human owns *deeply* rather than delegates. So M5 has more tasks and more code than M4.

---

## How this works: a throwaway container + your persistent workspace

Same throwaway-Docker-container setup as Modules 1–4, but with a critical addition: **your code
lives in a folder on your host machine** that is mounted into the container. Nuke the container —
your work survives.

- The orders API runs at **http://localhost:8080**. Reads are public; writes require a bearer token
  (`alice-token` for Alice, `bob-token` for Bob).
- The contract is **`workspace/orders-api.yaml`** (OpenAPI 3.0) — a deliberately incomplete draft
  that you fill in.
- Handler code lives in **`workspace/handlers/`** — one file per task, seeded fresh so you never
  lose work if you re-enter the sandbox.

### Two-terminal workflow

1. **In the container:** `lesson next` — read the task.
2. **On your host machine:** edit `workspace/handlers/` with AI (Claude Code, Cursor, etc.) or
   any editor. The contract YAML and handler files are on your real filesystem, not in the
   container — so your tools work normally.
3. **Back in the container:** `lesson check` — it **restarts the server** (picking up your edits)
   and runs a behavioral battery. Green means advance; red shows what's still wrong.

The AI never runs inside the container; the mount is the bridge.

### Step 1 — Install Docker (required)

If you did earlier modules you already have it. Otherwise `./sandbox` prints tailored instructions:
macOS → Docker Desktop (or `brew install --cask docker`); Linux →
`sudo apt-get install docker.io` then `sudo systemctl start docker`; Windows → Docker Desktop
(WSL2 backend), run `./sandbox` from a WSL2 shell.

### Step 2 — Enter the sandbox

```
./sandbox
```

This maps port 8080 out of the container and mounts your `workspace/` folder. Keep it running.

### Step 3 — Follow the guide

```
lesson next     # show the next task
lesson check    # restart server, verify your work (or answer a question); on success, advance
lesson hint     # a nudge (ask again for the exact command)
lesson map      # see all tasks
lesson jump N   # jump to task N
lesson reset    # start over
exit            # leave the container (it self-destructs; workspace/ stays on your host)
```

Two kinds of task: **do-something** tasks check real results (a YAML edit, a handler fix) with
`lesson check` running curl tests; **quiz** tasks ask a multiple-choice question.

---

## The four pillars

### 1. Contract-first — the OpenAPI spec is a first-class artifact you author before code

Module 4 taught *reading* a contract. Module 5 = *writing* it, including error cases and
status-code discipline. Every task starts with the contract, then the code follows.

### 2. Idempotency (marquee) — see a naive POST double-apply on retry

POST is not idempotent: same POST twice = two resources. You'll add an `Idempotency-Key` so a
retried create returns the *same* order, not a new one. This is the module's headline concept.

### 3. Never trust the client (core) — exploit-then-harden

The naive server trusts the client's price, status, and access control. You'll prove each exploit
works, then make the server authoritative — it computes prices from the catalog, controls status
transitions, and enforces owner-only access.

### 4. Failure semantics & real-time — timeouts, retries, websockets vs polling

Why retries *demand* idempotency; the difference between polling and WebSocket; delivery and
ordering caveats.

---

## The domain: a tiny store's orders API

- **Products** — a small fixed catalog (`GET /products`). The server owns prices.
- **Orders** — `POST /orders` (server computes total), `GET /orders` (paginated, owner-filtered),
  `GET /orders/{id}`, `POST /orders/{id}/cancel`, and the capstone refund endpoint.
- **Two demo users** — Alice (`alice-token`) and Bob (`bob-token`) so authorization is real.
- **Status lifecycle** — `pending → cancelled` (or `pending → paid → shipped → refunded` in the
  capstone). Server-authoritative: the client never sets status directly.

The server ships deliberately flawed — non-idempotent create, client-trusted price,
client-settable status, weak validation, broken owner-check, no pagination, wrong status codes.
Every task hardens one flaw.

---

## Task arc

| # | Pillar | What you do |
|---|---|---|
| 1 | Contract-first | Read the contract (quiz) |
| 2 | Contract-first | Status-code discipline (quiz) |
| 3 | Contract-first | Add 409 Conflict to the YAML |
| 4 | Contract-first | Add POST /orders/{id}/cancel to the YAML |
| 5 | Validation | Probe the naive server — observe missing validation (quiz) |
| 6 | Validation | Harden: reject qty≤0, unknown productId, missing items |
| 7 | Validation | Fix status codes: 201 for create, 404 for missing |
| 8 | Idempotency | Prove POST creates twice (quiz) |
| 9 | Idempotency | Prove cancel flip-flops (quiz) |
| 10 | Idempotency | Implement Idempotency-Key on create |
| 11 | Trust boundary | Exploit: forge totalCents (quiz) |
| 12 | Trust boundary | Harden: server computes total from catalog |
| 13 | Trust boundary | Harden: server-authoritative status lifecycle |
| 14 | Trust boundary | Harden: owner-only authorization (401 vs 403) |
| 15 | Scale/failure | Add pagination (?limit, ?offset) |
| 16 | Scale/failure | API versioning (quiz) |
| 17 | Scale/failure | Timeouts & retries — why idempotency matters (quiz) |
| 18 | Real-time | Polling vs WebSocket (probe/quiz) |
| 19 | Real-time | WS delivery/ordering caveats (quiz) |
| 20 | Capstone | POST /orders/{id}/refund — contract + handler + full battery |

---

## The mental model

### The contract is the artifact; code follows it

Write the YAML first — every endpoint, every response code, every error shape. Then implement
the handler to match. If the contract and code disagree, the contract wins. This is the
discipline that keeps AI-generated code honest: you defined what "correct" looks like before
the code existed.

### Never trust the client

The client can send *anything*. The server must validate everything and be the authority for
every computed field:
- **Prices** — computed from the catalog, never from the client
- **Status** — the server defines the state machine; the client sends commands, not values
- **Access** — the server checks ownership; a valid token ≠ permission to read every order

### Idempotency is not optional when retries exist

If a client retries after a timeout, the server can't tell whether the first request arrived.
Without idempotency, the retry creates a duplicate. The `Idempotency-Key` header lets the server
deduplicate: same key → same result.

### 401 vs 403: auth vs authorization

- **401** — "who are you?" No valid credentials. The client can retry with credentials.
- **403** — "I know who you are, but you may not do this." Credentials are valid but insufficient.
Getting this wrong (e.g., returning 404 for another user's order) leaks information or hides
the real error.

---

## Command cheat-sheet

| Goal | Command |
|---|---|
| List products | `curl http://localhost:8080/products` |
| List your orders | `curl http://localhost:8080/orders -H 'Authorization: Bearer alice-token'` |
| Create an order | `curl -X POST http://localhost:8080/orders -H 'Authorization: Bearer alice-token' -H 'Content-Type: application/json' -d '{"items":[{"productId":1,"qty":1}]}'` |
| Get one order | `curl http://localhost:8080/orders/1 -H 'Authorization: Bearer alice-token'` |
| Cancel an order | `curl -X POST http://localhost:8080/orders/1/cancel -H 'Authorization: Bearer alice-token'` |
| Create with idempotency | `curl -X POST ... -H 'Idempotency-Key: my-key-1' ...` |
| Paginated list | `curl 'http://localhost:8080/orders?limit=5&offset=0' -H 'Bearer alice-token'` |
| Restart server | `lesson check` does this automatically |

---

## The capstone: implement POST /orders/{id}/refund

The capstone combines everything:
1. **Contract-first** — add the refund endpoint to `orders-api.yaml`
2. **Server-authoritative** — refund transitions status, client doesn't set it
3. **Idempotency** — refunding twice returns the same state
4. **Owner-only** — only the order's user can refund it
5. **Correct codes** — 200 success, 404 not found, 403 forbidden, 409 wrong status

The conformance harness runs the full battery — good input, bad input, forged fields, retried
request, owner check, missing auth. The capstone is complete when the harness passes.

---

## Quiz

Test yourself with the interactive quiz — it grades itself and explains each answer. Open it in
your browser; on a Mac, from this directory:

```
open quizzes/module-5-quiz.html
```

(Linux: `xdg-open quizzes/module-5-quiz.html`; or double-click it.)

Once that feels easy, try the **advanced quiz** — harder, and it reaches past this module into
real-world HTTP (PATCH vs PUT, CORS preflight, ETags, rate limiting, TLS, OAuth2, gRPC, GraphQL,
422 vs 400, Retry-After). Anything you miss is worth knowing next time you design an API:

```
open quizzes/module-5-quiz-advanced.html
```

## What's next

You can now design an API contract, implement a server that enforces it, and harden the trust
boundary against exploits. From here the course moves into data modeling and integrity — where
the same contract-and-verify discipline meets relational databases and the most irreversible
mistakes in the stack.
