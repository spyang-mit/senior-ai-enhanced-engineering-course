# Drill 10 -- make create idempotent with an Idempotency-Key.
#
# Contract: if a create arrives with an Idempotency-Key header the server has
# seen before, it must return the SAME order it returned last time, instead of
# creating a second one. (This is what lets a client safely RETRY a create that
# timed out -- see the timeouts/retries task.)
#
# handle(req, ctx) -> (status, body)
#   req.header("Idempotency-Key")  the key, or None
#   ctx.idempotency                a dict you can use to remember keys -> orders
#   ctx.new_id(), ctx.orders, ctx.user, ctx.products as before

def handle(req, ctx):
    key = req.header("Idempotency-Key")

    # TODO(you): if `key` is set AND you've already stored an order for it in
    # ctx.idempotency, return that same order now (do NOT create a new one).

    items = req.body.get("items", [])
    total = sum(ctx.products[it["productId"]]["priceCents"] * it["qty"] for it in items)
    oid = ctx.new_id()
    order = {"id": oid, "userId": ctx.user, "items": items,
             "totalCents": total, "status": "pending"}
    ctx.orders[oid] = order

    # TODO(you): if `key` is set, remember this order under it so a retry finds it.
    return (201, order)
