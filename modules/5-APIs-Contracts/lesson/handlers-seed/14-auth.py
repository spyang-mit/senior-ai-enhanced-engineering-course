# Drill 14 -- authorization: only the owner may read an order.
#
# Contract: GET /orders/{id} returns the order only if the caller owns it;
# otherwise 404 (we don't even reveal that someone else's order exists).
#
# The naive handler returns any order to any authenticated user -- so Alice can
# read Bob's order. Add the ownership check.
#
# handle(req, ctx) -> (status, body)
#   req.order_id   the {id}
#   ctx.user       the authenticated caller
#   ctx.orders     dict of id -> order  (each has a "userId")

def handle(req, ctx):
    order = ctx.orders.get(req.order_id)
    if not order:
        return (404, {"error": "not found"})

    # TODO(you): only the owner may read it. If order["userId"] != ctx.user,
    # return 404 (don't leak that it exists). 401 vs 403 vs 404: the caller IS
    # authenticated (401 is for no/invalid token); here we choose 404 so we
    # don't confirm another user's order even exists.

    return (200, order)
