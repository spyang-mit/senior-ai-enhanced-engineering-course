# Drill 13 -- the order status is server-controlled, not client-supplied.
#
# Contract: a brand-new order is ALWAYS "pending". The lifecycle
# (pending -> paid -> shipped ...) is driven by the server, never by the create
# payload. The naive handler lets the client set status -- so anyone can create
# an order that's already "paid" without paying. Force it to "pending".
#
# handle(req, ctx) -> (status, body)

def handle(req, ctx):
    items = req.body.get("items", [])
    total = sum(ctx.products[it["productId"]]["priceCents"] * it["qty"] for it in items)

    # NAIVE BUG: takes the status from the client.
    status = req.body.get("status", "pending")
    # TODO(you): ignore any client-sent status; a new order is always "pending".

    oid = ctx.new_id()
    order = {"id": oid, "userId": ctx.user, "items": items,
             "totalCents": total, "status": status}
    ctx.orders[oid] = order
    return (201, order)
