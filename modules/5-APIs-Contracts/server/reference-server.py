#!/usr/bin/env python3
"""Module 5 orders API — reference server (read-only, learner can't break the harness).

Serves the orders API on port 8080 with a fixed product catalog, two demo users
(Alice, Bob), and deliberately FLAWED default implementations. Pluggable handlers
from the mounted workspace override specific endpoints as the learner hardens them.

The server imports handler functions from /home/dev/workspace/handlers/active.py
at startup. Each task's setup() symlinks the correct handler file there.
"""
import json, os, re, threading, sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# --- configuration -----------------------------------------------------------
HANDLER_FILE = "/home/dev/workspace/handlers/active.py"
ACCESS_LOG   = os.environ.get("ACCESS_LOG", "/tmp/access.log")
PORT         = int(os.environ.get("PORT", "8080"))

# --- product catalog (server-owned, never trusted from client) ----------------
PRODUCTS = [
    {"id": 1, "name": "Widget",    "priceCents": 2999},
    {"id": 2, "name": "Gadget",    "priceCents": 4999},
    {"id": 3, "name": "Doohickey", "priceCents": 999},
]
PRODUCT_BY_ID = {p["id"]: p for p in PRODUCTS}

# --- orders store (in-memory, deliberately flawed by default) ----------------
_lock = threading.Lock()
orders = {}          # order_id -> dict
_next_order_id = 1

# --- auth --------------------------------------------------------------------
# Two demo users. Tokens are deliberately simple strings so the learner can curl
# with a literal header. The server extracts the username from the token.
TOKENS = {
    "alice-token": "Alice",
    "bob-token":   "Bob",
}

def _auth_user(headers):
    """Extract authenticated username from bearer token. Returns None on failure."""
    hdr = headers.get("Authorization", "")
    if not hdr.startswith("Bearer "):
        return None
    token = hdr[7:].strip()
    return TOKENS.get(token)  # None if token unknown

# --- logging -----------------------------------------------------------------
def log(method, path, status):
    try:
        with open(ACCESS_LOG, "a") as f:
            f.write(f"{method} {path} {status}\n")
    except OSError:
        pass

# --- handler loading ---------------------------------------------------------
def load_handlers():
    """Load handler functions from the active handler file.
    Returns a dict of function name -> callable."""
    if not os.path.exists(HANDLER_FILE):
        return {}
    ns = {}
    with open(HANDLER_FILE) as f:
        code = compile(f.read(), HANDLER_FILE, "exec")
        exec(code, ns)
    return {k: v for k, v in ns.items() if k.startswith("handle_")}

HANDLERS = load_handlers()

def handler(name, default):
    """Get a handler function by name, falling back to the default."""
    return HANDLERS.get(name, default)

# =============================================================================
# Default (deliberately flawed) implementations
# =============================================================================

def default_create_order(data, user):
    """Naive create: non-idempotent, trusts client price, no validation."""
    # Accept any items without validation
    items = data.get("items", [])
    # Trust the client's totalCents if provided
    total = data.get("totalCents")
    if total is None:
        total = sum(PRODUCT_BY_ID.get(i.get("productId"), {}).get("priceCents", 0) * i.get("qty", 1)
                    for i in items)
    global _next_order_id
    with _lock:
        oid = _next_order_id
        _next_order_id += 1
        order = {
            "id": oid,
            "userId": user,
            "status": "pending",
            "items": items,
            "totalCents": total,
        }
        orders[oid] = order
    return 201, order

def default_get_orders(query, user):
    """Naive list: returns ALL orders (no owner filter), no pagination."""
    with _lock:
        # Deliberate flaw: returns every order, not just the caller's
        items = list(orders.values())
    return 200, items

def default_get_order(order_id, user):
    """Naive get: returns the order with no owner check."""
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    return 200, order

def default_cancel_order(order_id, user):
    """Naive cancel: no owner check, no idempotency."""
    with _lock:
        order = orders.get(order_id)
        if order is None:
            return 404, {"error": "order not found"}
        # Flaw: client can cancel ANY order, not just their own
        # Flaw: cancelling twice changes status each time
        if order["status"] == "pending":
            order["status"] = "cancelled"
        elif order["status"] == "cancelled":
            order["status"] = "pending"  # flip-flop! wrong
        else:
            return 409, {"error": "order cannot be cancelled"}
    return 200, order

def default_paginated_orders(query, user):
    """Naive pagination: ignores limit/offset."""
    return default_get_orders(query, user)

# =============================================================================
# HTTP handler
# =============================================================================

class Handler(BaseHTTPRequestHandler):
    server_version = "OrdersAPI/1.0"

    def log_message(self, *a):
        pass  # silence default stderr logging

    # --- helpers -------------------------------------------------------------
    def _path(self):
        return self.path.split("?", 1)[0]

    def _query(self):
        if "?" not in self.path:
            return {}
        q = {}
        for part in self.path.split("?", 1)[1].split("&"):
            if "=" in part:
                k, v = part.split("=", 1)
                q[k] = v
        return q

    def _send_json(self, status, obj):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, Idempotency-Key")
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)
        log(self.command, self._path(), status)

    def _send_status(self, status):
        self.send_response(status)
        self.send_header("Content-Length", "0")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, Idempotency-Key")
        self.end_headers()
        log(self.command, self._path(), status)

    def _body(self):
        n = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(n) if n else b""
        try:
            return json.loads(raw or b"{}")
        except json.JSONDecodeError:
            return None

    def _order_id(self):
        m = re.fullmatch(r"/orders/(\d+)(?:/(cancel|refund))?", self._path())
        if m:
            return int(m.group(1)), m.group(2)  # (id, action) or (id, None)
        m = re.fullmatch(r"/orders/(\d+)", self._path())
        return (int(m.group(1)), None) if m else None

    # --- verbs ---------------------------------------------------------------
    def do_OPTIONS(self):
        self._send_status(204)

    def do_GET(self):
        p = self._path()
        if p == "/products":
            return self._send_json(200, PRODUCTS)
        if p == "/orders":
            q = self._query()
            user = _auth_user(self.headers)
            if user is None:
                return self._send_json(401, {"error": "missing or invalid bearer token"})
            # Use handler if loaded, else default
            fn = handler("handle_paginated_orders", default_paginated_orders)
            status, body = fn(q, user)
            return self._send_json(status, body)
        oid = self._order_id()
        if oid is not None:
            oid, action = oid
            user = _auth_user(self.headers)
            if user is None:
                return self._send_json(401, {"error": "missing or invalid bearer token"})
            fn = handler("handle_get_order", default_get_order)
            status, body = fn(oid, user)
            return self._send_json(status, body)
        return self._send_json(404, {"error": "not found"})

    def do_POST(self):
        p = self._path()
        user = _auth_user(self.headers)
        if user is None:
            return self._send_json(401, {"error": "missing or invalid bearer token"})

        data = self._body()
        if data is None:
            return self._send_json(400, {"error": "body must be valid JSON"})

        if p == "/orders":
            fn = handler("handle_create_order", default_create_order)
            status, body = fn(data, user)
            return self._send_json(status, body)

        # POST /orders/{id}/cancel
        oid = self._order_id()
        if oid is not None:
            oid, action = oid
            if action == "cancel":
                fn = handler("handle_cancel_order", default_cancel_order)
                status, body = fn(oid, user)
                return self._send_json(status, body)

        return self._send_json(404, {"error": "not found"})

if __name__ == "__main__":
    open(ACCESS_LOG, "a").close()
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
