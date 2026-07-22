# Drill 12 -- never trust the client's price. The server computes the total.
#
# Contract: totalCents is server-authoritative. The client sends only items
# (productId + qty). Any client-sent total/price MUST be ignored.
#
# The naive handler below trusts a client-sent totalCents -- so a shopper can
# forge a $0.01 order. Compute the total yourself from ctx.products instead.
#
# handle(req, ctx) -> (status, body)

def handle(req, ctx):
    items = req.body.get("items", [])

    # NAIVE BUG: trusts a client-sent total (defaults to 0 if absent).
    total = req.body.get("totalCents", 0)
    # TODO(you): ignore any client-sent total. Compute it from ctx.products --
    # the sum of priceCents * qty across items.

    oid = ctx.new_id()
    order = {"id": oid, "userId": ctx.user, "items": items,
             "totalCents": total, "status": "pending"}
    ctx.orders[oid] = order
    return (201, order)
