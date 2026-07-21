"""
Task 15 — Pagination.

Current flaw:
  • GET /orders ignores limit/offset — returns everything.
  • No total count.

Fix: honor ?limit=N&offset=M. Return a paginated envelope with `items` and `total`.
"""

import threading

_idem_lock = threading.Lock()
_idem_store = {}

def handle_create_order(data, user, idempotency_key=None):
    if idempotency_key:
        with _idem_lock:
            if idempotency_key in _idem_store:
                oid = _idem_store[idempotency_key]
                from reference_server import orders
                with _idem_lock:
                    order = orders.get(oid)
                if order:
                    return 200, order

    items = data.get("items")
    if not items:
        return 400, {"error": "items is required"}
    if not isinstance(items, list) or len(items) == 0:
        return 400, {"error": "items must be a non-empty array"}
    for i, item in enumerate(items):
        pid = item.get("productId")
        qty = item.get("qty", 0)
        if pid is None or not isinstance(pid, int):
            return 400, {"error": f"items[{i}].productId is required"}
        if qty is None or not isinstance(qty, int) or qty <= 0:
            return 400, {"error": f"items[{i}].qty must be a positive integer"}
        from reference_server import PRODUCT_BY_ID
        if pid not in PRODUCT_BY_ID:
            return 400, {"error": f"unknown productId: {pid}"}

    total = 0
    for item in items:
        from reference_server import PRODUCT_BY_ID
        price = PRODUCT_BY_ID[item["productId"]]["priceCents"]
        total += price * item["qty"]

    from reference_server import _next_order_id, orders
    import threading as _t
    _l = _t.Lock()
    with _l:
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

    if idempotency_key:
        with _idem_lock:
            _idem_store[idempotency_key] = oid

    return 201, order

def handle_get_order(order_id, user):
    import threading
    _lock = threading.Lock()
    from reference_server import orders
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    if order["userId"] != user:
        return 403, {"error": "forbidden: this order belongs to another user"}
    return 200, order

def handle_cancel_order(order_id, user):
    import threading
    _lock = threading.Lock()
    from reference_server import orders
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    if order["userId"] != user:
        return 403, {"error": "forbidden: this order belongs to another user"}
    if order["status"] == "pending":
        order["status"] = "cancelled"
        return 200, order
    elif order["status"] == "cancelled":
        return 200, order
    else:
        return 409, {"error": "order cannot be cancelled in current status"}

def handle_paginated_orders(query, user):
    """List orders with pagination."""
    import threading
    _lock = threading.Lock()
    from reference_server import orders
    with _lock:
        all_items = [o for o in orders.values() if o["userId"] == user]

    total = len(all_items)
    limit = 20  # default page size
    offset = 0
    try:
        limit = int(query.get("limit", 20))
        if limit < 1: limit = 20
    except ValueError:
        limit = 20
    try:
        offset = int(query.get("offset", 0))
        if offset < 0: offset = 0
    except ValueError:
        offset = 0

    page = all_items[offset:offset + limit]
    return 200, {"items": page, "total": total}
