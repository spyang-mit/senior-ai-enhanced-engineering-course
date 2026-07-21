# Drill 15 -- list YOUR orders, paginated.
#
# Contract: GET /orders returns only the caller's orders, as
#   {"total": <count of the caller's orders>, "items": [<one page>]}
# honoring ?limit (default 20) and ?offset (default 0).
#
# The naive handler returns EVERY order (all users), unpaginated, in the wrong
# shape. Fix all three.
#
# handle(req, ctx) -> (status, body)
#   req.query      {"limit": "2", "offset": "0"}  -- values are STRINGS
#   ctx.user       the caller
#   ctx.orders     dict of id -> order

def handle(req, ctx):
    # NAIVE BUG: every order, everyone's, no pagination, wrong shape.
    all_orders = list(ctx.orders.values())

    # TODO(you):
    #   1) keep only orders where userId == ctx.user
    #   2) read limit/offset from req.query (they're strings; default 20 / 0)
    #   3) return (200, {"total": <count of the caller's orders>,
    #                    "items": <the requested slice>})

    return (200, all_orders)
