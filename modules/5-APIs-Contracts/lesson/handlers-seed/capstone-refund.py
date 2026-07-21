# CAPSTONE -- implement POST /orders/{id}/refund from the contract you extended.
#
# This is yours to build. The conformance harness (lesson check) enforces the
# contract; make every requirement below true.
#
# Requirements:
#   * Only the order's OWNER may refund it. A non-owner gets 404 (don't leak
#     that someone else's order exists).
#   * A missing order -> 404.
#   * On success -> 200, set the order's status to "refunded", and return
#     {"refundedCents": <the order's server-side totalCents>}. Never trust a
#     client-supplied amount.
#   * Idempotent: a retry with the same Idempotency-Key must not refund twice --
#     return 200 with the same refundedCents.
#
# handle(req, ctx) -> (status, body)
#   req.order_id                    the {id} from the path
#   req.header("Idempotency-Key")   the key, or None
#   ctx.user, ctx.orders, ctx.idempotency are available.

def handle(req, ctx):
    # TODO(you): implement the refund per the contract above.
    raise NotImplementedError("implement the refund handler")
