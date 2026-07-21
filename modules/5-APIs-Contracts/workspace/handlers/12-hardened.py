"""
Task 12 — Server computes the total; ignore client price.

Current flaw:
  • The server trusts client-provided totalCents — a learner can forge a cheap order.

Fix: always compute totalCents from the catalog × quantities. Ignore any
totalCents in the request body.

Also keep idempotency-key support from Task 10.
"""

import threading

_idem_lock = threading.Lock()
_idem_store = {}

def handle_create_order(data, user, idempotency_key=None):
    """Create order — server-authoritative total, ignore client price."""
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

    # Compute total from catalog — ignore any client-supplied totalCents
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
            "totalCents": total,  # server-computed, not from client
        }
        orders[oid] = order

    if idempotency_key:
        with _idem_lock:
            _idem_store[idempotency_key] = oid

    return 201, order
