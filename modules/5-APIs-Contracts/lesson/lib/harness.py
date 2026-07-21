#!/usr/bin/env python3
"""
Behavioral conformance harness for Module 5.

Each hardening drill (and the capstone) is a self-contained handler the learner
edits in workspace/. A handler is a function:

    def handle(req, ctx) -> (status_code, body_dict)

The harness imports the learner's file, builds request/context objects, and
fires a battery of requests -- good input, bad input, forged fields, retries --
asserting on the status codes and bodies the contract requires. It is fully
isolated per drill: no network, no shared state between checks.

Usage:  python3 harness.py <drill> <path-to-handler.py>
Exit:   0 = all checks passed, 1 = a check failed, 3 = handler wouldn't import.
"""
import copy
import importlib.util
import sys
import traceback

# Same catalog the reference server prices from -- the contract's source of truth.
PRODUCTS = {
    1: {"id": 1, "name": "Widget", "priceCents": 500},
    2: {"id": 2, "name": "Gadget", "priceCents": 1200},
    3: {"id": 3, "name": "Gizmo", "priceCents": 250},
}

GREEN, RED, DIM, RESET = "\033[32m", "\033[31m", "\033[2m", "\033[0m"


class Req:
    def __init__(self, method="POST", body=None, headers=None, query=None,
                 order_id=None, path="/orders"):
        self.method = method
        self.body = body if body is not None else {}
        # header lookups are case-insensitive
        self.headers = {k.lower(): v for k, v in (headers or {}).items()}
        self.query = query or {}
        self.order_id = order_id
        self.path = path

    def header(self, name, default=None):
        return self.headers.get(name.lower(), default)


class Ctx:
    def __init__(self, user="alice", orders=None):
        self.products = copy.deepcopy(PRODUCTS)
        self.orders = orders if orders is not None else {}
        self.user = user
        self.idempotency = {}
        self._next = 1000

    def new_id(self):
        self._next += 1
        return self._next


class Checker:
    def __init__(self):
        self.ok = True

    def check(self, desc, cond, detail=""):
        if cond:
            print(f"  {GREEN}✓{RESET} {desc}")
        else:
            self.ok = False
            print(f"  {RED}✗{RESET} {desc}" + (f"  {DIM}({detail}){RESET}" if detail else ""))


def _call(handler, req, ctx):
    """Call the learner's handle(), tolerating (status, body) or a bad return."""
    try:
        out = handler(req, ctx)
    except Exception as e:  # a runtime error in the handler is a failed check
        return None, {"__error__": f"{type(e).__name__}: {e}"}
    if not (isinstance(out, tuple) and len(out) == 2):
        return None, {"__error__": f"handle() must return (status, body), got {out!r}"}
    return out


# --- drills -----------------------------------------------------------------

def drill_validate(h):
    c = Checker()
    ctx = Ctx()
    s, b = _call(h, Req(body={"items": [{"productId": 1, "qty": 2}]}), ctx)
    c.check("valid order -> 201", s == 201, f"got {s}: {b}")
    c.check("valid order total computed server-side (2 x 500 = 1000)",
            isinstance(b, dict) and b.get("totalCents") == 1000, f"got {b}")
    s, b = _call(h, Req(body={"items": [{"productId": 1, "qty": 0}]}), Ctx())
    c.check("qty < 1 -> 400", s == 400, f"got {s}: {b}")
    s, b = _call(h, Req(body={"items": [{"productId": 999, "qty": 1}]}), Ctx())
    c.check("unknown productId -> 400", s == 400, f"got {s}: {b}")
    s, b = _call(h, Req(body={"items": []}), Ctx())
    c.check("empty items -> 400", s == 400, f"got {s}: {b}")
    return c.ok


def drill_codes(h):
    c = Checker()
    s, b = _call(h, Req(method="POST", body={"items": [{"productId": 1, "qty": 1}]}), Ctx())
    c.check("create -> 201 (not 200)", s == 201, f"got {s}")
    s, b = _call(h, Req(method="GET", order_id=424242,
                        path="/orders/424242"), Ctx(orders={1: {"id": 1, "userId": "alice"}}))
    c.check("GET a missing order -> 404", s == 404, f"got {s}")
    return c.ok


def drill_idempotent(h):
    c = Checker()
    ctx = Ctx()
    body = {"items": [{"productId": 1, "qty": 1}]}
    s1, b1 = _call(h, Req(body=body, headers={"Idempotency-Key": "k1"}), ctx)
    c.check("first create -> 201", s1 == 201, f"got {s1}: {b1}")
    id1 = b1.get("id") if isinstance(b1, dict) else None
    s2, b2 = _call(h, Req(body=body, headers={"Idempotency-Key": "k1"}), ctx)
    id2 = b2.get("id") if isinstance(b2, dict) else None
    c.check("retry with SAME key returns the SAME order", id1 is not None and id1 == id2,
            f"first id={id1}, retry id={id2}")
    c.check("retry did NOT create a second order", len(ctx.orders) == 1,
            f"orders now = {len(ctx.orders)}")
    s3, b3 = _call(h, Req(body=body, headers={"Idempotency-Key": "k2"}), ctx)
    id3 = b3.get("id") if isinstance(b3, dict) else None
    c.check("a DIFFERENT key creates a new order", id3 is not None and id3 != id1,
            f"id3={id3}, id1={id1}")
    return c.ok


def drill_price(h):
    c = Checker()
    # client forges a cheap total and a price; server must ignore both.
    req = Req(body={"items": [{"productId": 2, "qty": 1}], "totalCents": 1, "price": 1})
    s, b = _call(h, req, Ctx())
    c.check("create -> 201", s == 201, f"got {s}: {b}")
    c.check("server computes total from the catalog (1 x 1200 = 1200), ignoring the forged 1",
            isinstance(b, dict) and b.get("totalCents") == 1200, f"got totalCents={b.get('totalCents') if isinstance(b, dict) else b}")
    return c.ok


def drill_status(h):
    c = Checker()
    req = Req(body={"items": [{"productId": 1, "qty": 1}], "status": "paid"})
    s, b = _call(h, req, Ctx())
    c.check("create -> 201", s == 201, f"got {s}: {b}")
    c.check("server forces status to 'pending', ignoring the client's 'paid'",
            isinstance(b, dict) and b.get("status") == "pending", f"got status={b.get('status') if isinstance(b, dict) else b}")
    return c.ok


def drill_auth(h):
    c = Checker()
    seed = {1: {"id": 1, "userId": "alice", "items": [], "totalCents": 0, "status": "pending"},
            2: {"id": 2, "userId": "bob", "items": [], "totalCents": 0, "status": "pending"}}
    # alice reading her own order
    s, b = _call(h, Req(method="GET", order_id=1, path="/orders/1"),
                 Ctx(user="alice", orders=copy.deepcopy(seed)))
    c.check("owner can read their own order -> 200", s == 200, f"got {s}: {b}")
    # alice reading bob's order
    s, b = _call(h, Req(method="GET", order_id=2, path="/orders/2"),
                 Ctx(user="alice", orders=copy.deepcopy(seed)))
    c.check("reading someone else's order is refused (403 or 404)", s in (403, 404), f"got {s}: {b}")
    c.check("...and does NOT leak the other user's order body",
            not (isinstance(b, dict) and b.get("userId") == "bob"), f"leaked: {b}")
    return c.ok


def drill_pagination(h):
    c = Checker()
    seed = {}
    for i in range(1, 6):  # 5 orders for alice
        seed[i] = {"id": i, "userId": "alice", "items": [], "totalCents": 0, "status": "pending"}
    for i in range(6, 8):  # 2 for bob
        seed[i] = {"id": i, "userId": "bob", "items": [], "totalCents": 0, "status": "pending"}
    s, b = _call(h, Req(method="GET", path="/orders", query={"limit": "2", "offset": "0"}),
                 Ctx(user="alice", orders=copy.deepcopy(seed)))
    c.check("list -> 200", s == 200, f"got {s}: {b}")
    c.check("total counts only the caller's orders (5, not 7)",
            isinstance(b, dict) and b.get("total") == 5, f"got total={b.get('total') if isinstance(b, dict) else b}")
    items = b.get("items") if isinstance(b, dict) else None
    c.check("limit=2 returns 2 items", isinstance(items, list) and len(items) == 2, f"got {items}")
    c.check("returned items belong to the caller",
            isinstance(items, list) and all(it.get("userId") == "alice" for it in items), f"got {items}")
    s, b = _call(h, Req(method="GET", path="/orders", query={"limit": "2", "offset": "4"}),
                 Ctx(user="alice", orders=copy.deepcopy(seed)))
    items = b.get("items") if isinstance(b, dict) else None
    c.check("offset=4,limit=2 returns the last 1 of 5", isinstance(items, list) and len(items) == 1, f"got {items}")
    return c.ok


def drill_refund(h):
    """Capstone: POST /orders/{id}/refund. Full battery."""
    c = Checker()

    def seed():
        return {1: {"id": 1, "userId": "alice", "items": [{"productId": 1, "qty": 2}],
                    "totalCents": 1000, "status": "paid"},
                2: {"id": 2, "userId": "bob", "items": [], "totalCents": 500, "status": "paid"}}

    # happy path: owner refunds their paid order
    ctx = Ctx(user="alice", orders=seed())
    s, b = _call(h, Req(method="POST", order_id=1, path="/orders/1/refund",
                        headers={"Idempotency-Key": "r1"}), ctx)
    c.check("owner refunds their order -> 200", s == 200, f"got {s}: {b}")
    c.check("order status becomes 'refunded'",
            ctx.orders[1]["status"] == "refunded", f"got {ctx.orders[1]['status']}")
    c.check("refund amount is the server's total (1000), not client-supplied",
            isinstance(b, dict) and b.get("refundedCents") == 1000, f"got {b}")
    # idempotent retry
    s2, b2 = _call(h, Req(method="POST", order_id=1, path="/orders/1/refund",
                          headers={"Idempotency-Key": "r1"}), ctx)
    c.check("retry with same key -> 200 and no double refund",
            s2 == 200 and isinstance(b2, dict) and b2.get("refundedCents") == 1000, f"got {s2}: {b2}")
    # authorization: bob cannot refund alice's order
    s, b = _call(h, Req(method="POST", order_id=1, path="/orders/1/refund",
                        headers={"Idempotency-Key": "x"}), Ctx(user="bob", orders=seed()))
    c.check("a non-owner cannot refund (403 or 404)", s in (403, 404), f"got {s}: {b}")
    # missing order
    s, b = _call(h, Req(method="POST", order_id=999, path="/orders/999/refund"),
                 Ctx(user="alice", orders=seed()))
    c.check("refunding a missing order -> 404", s == 404, f"got {s}: {b}")
    return c.ok


DRILLS = {
    "validate": drill_validate,
    "codes": drill_codes,
    "idempotent": drill_idempotent,
    "price": drill_price,
    "status": drill_status,
    "auth": drill_auth,
    "pagination": drill_pagination,
    "refund": drill_refund,
}


def load_handler(path):
    spec = importlib.util.spec_from_file_location("learner_handler", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)  # may raise -> caught by caller
    if not hasattr(mod, "handle"):
        raise AttributeError("your file must define a function named handle(req, ctx)")
    return mod.handle


def main():
    if len(sys.argv) != 3:
        print("usage: harness.py <drill> <handler.py>")
        sys.exit(2)
    drill, path = sys.argv[1], sys.argv[2]
    if drill not in DRILLS:
        print(f"unknown drill: {drill}")
        sys.exit(2)
    try:
        handler = load_handler(path)
    except FileNotFoundError:
        print(f"{RED}Could not find your handler file:{RESET} {path}")
        print("Run 'lesson next' to reseed this task's starter file.")
        sys.exit(3)
    except Exception:
        print(f"{RED}Your handler didn't load -- fix the error and try again:{RESET}")
        traceback.print_exc()
        sys.exit(3)
    ok = DRILLS[drill](handler)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
