# Drill 6 -- validate the create payload at the boundary.
#
# Contract (orders-api.yaml, POST /orders):
#   * 400 + {"error": "..."} when items is empty, any qty < 1, or a productId
#     is unknown.
#   * otherwise 201 with a server-computed total and status "pending".
#
# The naive handler below creates the order WITHOUT checking anything (an
# unknown product even crashes it). Reject bad input with 400 BEFORE creating.
#
# handle(req, ctx) -> (status, body)
#   req.body        the parsed JSON body, e.g. {"items": [{"productId":1,"qty":2}]}
#   ctx.products    {id: {"id","name","priceCents"}}  -- the price source of truth
#   ctx.user        the authenticated user id
#   ctx.new_id()    a fresh order id
#   ctx.orders      dict of id -> order (store the new order here)

def handle(req, ctx):
    items = req.body.get("items", [])

    # TODO(you): validate `items` and return (400, {"error": "..."}) when it is
    # empty, when any qty < 1, or when any productId is not in ctx.products.

    total = 0
    for it in items:
        p = ctx.products.get(it["productId"])
        total += p["priceCents"] * it["qty"]   # naive: assumes the product exists

    oid = ctx.new_id()
    order = {"id": oid, "userId": ctx.user, "items": items,
             "totalCents": total, "status": "pending"}
    ctx.orders[oid] = order
    return (201, order)
