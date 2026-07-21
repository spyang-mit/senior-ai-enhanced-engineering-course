#!/usr/bin/env python3
"""
Orders API -- the NAIVE reference server for Module 5, on :8080.

This is the "before" you probe and exploit: it is deliberately flawed in the
exact ways the lesson teaches. It trusts the client (price, status), skips
validation, has no ownership check, returns wrong status codes, isn't
idempotent, and doesn't paginate. You never edit this file -- you SEE the bugs
here, then implement the fix in workspace/handlers/, which `lesson check` tests
in isolation.

Stdlib only. Data is in-memory and resets when the server restarts.
"""
import json
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# --- The world -------------------------------------------------------------

PRODUCTS = {
    1: {"id": 1, "name": "Widget", "priceCents": 500},
    2: {"id": 2, "name": "Gadget", "priceCents": 1200},
    3: {"id": 3, "name": "Gizmo", "priceCents": 250},
}

# Bearer token -> user id. Two users so "Alice must not read Bob's order" is real.
TOKENS = {"alice-token": "alice", "bob-token": "bob"}

# Seed orders: one owned by alice, one by bob.
ORDERS = {
    1: {"id": 1, "userId": "alice", "items": [{"productId": 1, "qty": 2}],
        "totalCents": 1000, "status": "pending"},
    2: {"id": 2, "userId": "bob", "items": [{"productId": 2, "qty": 1}],
        "totalCents": 1200, "status": "pending"},
}
_next_id = 3
_lock = threading.Lock()


def _demo_status_loop():
    """Advance order 1's status on a timer so the polling-vs-websocket task has
    something that visibly changes between polls. Cycles for demo purposes."""
    cycle = ["pending", "paid", "shipped"]
    i = 0
    while True:
        time.sleep(4)
        with _lock:
            if 1 in ORDERS:
                i = (i + 1) % len(cycle)
                ORDERS[1]["status"] = cycle[i]


class Handler(BaseHTTPRequestHandler):
    server_version = "OrdersAPI/naive"

    def log_message(self, *a):  # keep the console quiet
        pass

    # -- helpers ------------------------------------------------------------
    def _json(self, status, obj):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _user(self):
        """Return the user id for the bearer token, or None."""
        auth = self.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            return TOKENS.get(auth[7:].strip())
        return None

    def _body(self):
        n = int(self.headers.get("Content-Length", 0) or 0)
        if not n:
            return {}
        try:
            return json.loads(self.rfile.read(n) or b"{}")
        except Exception:
            return {}

    # -- routes -------------------------------------------------------------
    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/products":
            return self._json(200, list(PRODUCTS.values()))
        if path == "/orders":
            user = self._user()
            if not user:
                return self._json(401, {"error": "missing or invalid token"})
            # NAIVE BUG: returns EVERY order (no owner filter), and no pagination.
            return self._json(200, list(ORDERS.values()))
        if path.startswith("/orders/"):
            user = self._user()
            if not user:
                return self._json(401, {"error": "missing or invalid token"})
            try:
                oid = int(path.split("/")[2])
            except (ValueError, IndexError):
                return self._json(404, {"error": "not found"})
            with _lock:
                order = ORDERS.get(oid)
            if not order:
                return self._json(404, {"error": "not found"})
            # NAIVE BUG: no ownership check -- returns anyone's order.
            return self._json(200, order)
        return self._json(404, {"error": "not found"})

    def do_POST(self):
        global _next_id
        path = self.path.split("?", 1)[0]
        user = self._user()
        if not user:
            return self._json(401, {"error": "missing or invalid token"})

        if path == "/orders":
            body = self._body()
            items = body.get("items", [])
            with _lock:
                oid = _next_id
                _next_id += 1
                order = {
                    "id": oid,
                    "userId": user,
                    "items": items,
                    # NAIVE BUG: trusts the client's total if sent, else 0. No
                    # server-side pricing. And trusts a client-sent status.
                    "totalCents": body.get("totalCents", 0),
                    "status": body.get("status", "pending"),
                }
                ORDERS[oid] = order
            # NAIVE BUG: ignores Idempotency-Key (a retry makes a 2nd order),
            # skips validation, and returns 200 instead of 201.
            return self._json(200, order)

        if path.startswith("/orders/") and path.endswith("/cancel"):
            try:
                oid = int(path.split("/")[2])
            except (ValueError, IndexError):
                return self._json(404, {"error": "not found"})
            with _lock:
                order = ORDERS.get(oid)
                if not order:
                    return self._json(404, {"error": "not found"})
                order["status"] = "cancelled"
            return self._json(200, order)

        return self._json(404, {"error": "not found"})


def main():
    threading.Thread(target=_demo_status_loop, daemon=True).start()
    srv = ThreadingHTTPServer(("0.0.0.0", 8080), Handler)
    print("naive orders API on :8080")
    srv.serve_forever()


if __name__ == "__main__":
    main()
