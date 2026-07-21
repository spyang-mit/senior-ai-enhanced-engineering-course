"""
Task 13 — Server-authoritative status.

Current flaw:
  • Client can set the order status in the request body.
  • Server accepts whatever status the client sends.

Fix: the server ALWAYS sets status to "pending" on create and NEVER accepts
a client-provided status. Cancel/refund transitions are also server-controlled.
"""

import threading

_idem_lock = threading.Lock()
_idem_store = {}

def handle_create_order(data, user, idempotency_key=None):
    """Create order — server-authoritative status, ignore client status."""
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
            "status": "pending",  # ALWAYS pending on create, never from client
            "items": items,
            "totalCents": total,
        }
        orders[oid] = order

    if idempotency_key:
        with _idem_lock:
            _idem_store[idempotency_key] = oid

    return 201, order

def handle_cancel_order(order_id, user):
    """Cancel — server-authoritative status transition."""
    import threading
    _lock = threading.Lock()
    from reference_server import orders
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    # Server controls the status transition
    if order["status"] == "pending":
        order["status"] = "cancelled"
        return 200, order
    elif order["status"] == "cancelled":
        # Idempotent: cancelling again returns the same state
        return 200, order
    else:
        return 409, {"error": "order cannot be cancelled in current status"}
