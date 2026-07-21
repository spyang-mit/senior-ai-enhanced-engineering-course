"""
Task 7 — Right status codes.

Current flaws:
  • POST /orders returns 200 instead of 201 on success
  • GET /orders/{id} for missing order returns 200 with null instead of 404

Fix: create → 201, missing → 404.
"""

def handle_create_order(data, user):
    """Create an order with correct status codes."""
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

    import threading
    _lock = threading.Lock()
    from reference_server import _next_order_id, orders
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
    return 201, order  # 201, not 200

def handle_get_order(order_id, user):
    """Get one order — return 404 if missing."""
    import threading
    _lock = threading.Lock()
    from reference_server import orders
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    return 200, order
