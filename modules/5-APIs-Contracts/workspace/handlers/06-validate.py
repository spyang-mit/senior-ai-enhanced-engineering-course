"""
Task 6 — Validate at the boundary.

Current flaws:
  • qty <= 0 is accepted
  • unknown productId is accepted
  • missing items array is accepted

Harden: reject qty <= 0 → 400, unknown productId → 400, missing items → 400.

Shared state available (no imports needed):
  PRODUCT_BY_ID — dict of productId -> product dict
  orders        — dict of order_id -> order dict
  _next_id_counter[0] — next id to assign
  _lock         — threading.Lock for orders store
"""

def handle_create_order(data, user):
    """Validate input, then create the order."""
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

    # Compute total from catalog
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
            "status": "pending",
            "items": items,
            "totalCents": total,
        }
        orders[oid] = order
    return 201, order
