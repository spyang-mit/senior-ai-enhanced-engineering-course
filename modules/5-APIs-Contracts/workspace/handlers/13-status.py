"""
Task 13 — Server-authoritative status.

Current flaw:
  • Client can set the order status in the request body.
  • Server accepts whatever status the client sends.

Fix: the server ALWAYS sets status to "pending" on create and NEVER accepts
a client-provided status. Cancel/refund transitions are also server-controlled.

Shared state available (no imports needed):
  PRODUCT_BY_ID, orders, _next_id_counter[0], _lock
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
        if pid not in PRODUCT_BY_ID:
            return 400, {"error": f"unknown productId: {pid}"}

    total = 0
    for item in items:
        price = PRODUCT_BY_ID[item["productId"]]["priceCents"]
        total += price * item["qty"]

    with _lock:
        oid = _next_id_counter[0]
        _next_id_counter[0] += 1
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
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    if order["status"] == "pending":
        order["status"] = "cancelled"
        return 200, order
    elif order["status"] == "cancelled":
        return 200, order
    else:
        return 409, {"error": "order cannot be cancelled in current status"}
