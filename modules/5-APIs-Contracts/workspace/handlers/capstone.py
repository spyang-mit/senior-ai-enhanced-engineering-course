"""
Task 20 — Capstone: implement POST /orders/{id}/refund from scratch.

The contract does not include this endpoint yet — you must:
  1. Add it to orders-api.yaml
  2. Implement the handler here

Requirements:
  • Owner-only: only the order's user can refund it
  • Status transition: only "paid" or "shipped" orders can be refunded
  • Idempotent: refunding twice returns the same state
  • Server-authoritative: status changes, not client-settable
  • Correct codes: 200 success, 404 not found, 403 forbidden, 409 wrong status

Shared state available (no imports needed):
  PRODUCT_BY_ID, orders, _next_id_counter[0], _lock
"""

import threading

_idem_lock = threading.Lock()
_idem_store = {}

def handle_refund_order(order_id, user):
    """Refund an order. (Stub — learner completes this.)"""
    with _lock:
        order = orders.get(order_id)
    if order is None:
        return 404, {"error": "order not found"}
    # TODO: owner check
    # TODO: status transition (pending/cancelled → 409)
    # TODO: idempotent (already refunded → return same)
    # TODO: correct status code
    order["status"] = "refunded"
    return 200, order
