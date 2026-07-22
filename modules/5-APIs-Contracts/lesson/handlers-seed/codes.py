# Drill 7 -- return the right status codes.
#
# Contract: a successful create is 201 Created (not 200); a GET for an order
# that doesn't exist is 404 Not Found (not 200).
#
# handle(req, ctx) -> (status, body)
#   req.method    "POST" (create) or "GET" (fetch one)
#   req.order_id  the {id} on a GET
#   ctx.orders    dict of id -> order

def handle(req, ctx):
    if req.method == "POST":
        items = req.body.get("items", [])
        total = sum(ctx.products[it["productId"]]["priceCents"] * it["qty"] for it in items)
        oid = ctx.new_id()
        order = {"id": oid, "userId": ctx.user, "items": items,
                 "totalCents": total, "status": "pending"}
        ctx.orders[oid] = order
        # TODO(you): a successful create should be 201 Created, not 200.
        return (200, order)

    if req.method == "GET":
        order = ctx.orders.get(req.order_id)
        # TODO(you): if there is no such order, return 404 (not 200 with null).
        return (200, order)

    return (404, {"error": "not found"})
