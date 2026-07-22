# shellcheck shell=bash disable=SC2034
TASK_TITLE="Harden: server owns the price"
TASK_CAT="Never trust the client"
TASK_BODY="Close the hole you just found. In:
  ~/workspace/handlers/price.py
make the server compute totalCents itself — sum of priceCents * qty from
ctx.products — and IGNORE any total the client sent. The client sends only items.

Edit it on your host, then run 'lesson check'. The harness sends a forged cheap
total and confirms your handler prices it from the catalog anyway."
TASK_TRY="less ~/workspace/handlers/price.py"
TASK_WHY="'Server-authoritative' is the durable fix, not 'validate the client's
number.' You don't check that the forged price is plausible — you refuse to read
it at all and compute the truth yourself."
TASK_HINTS=(
  "The naive line reads the total from req.body. Replace it: compute total from ctx.products and the items' quantities."
  "total = sum(ctx.products[it['productId']]['priceCents'] * it['qty'] for it in items)"
  "Ask your AI: 'compute the order total from ctx.products server-side; ignore any client-sent totalCents.'"
)
TASK_GOAL="Compute totalCents on the server, ignoring the client — edit ~/workspace/handlers/price.py"
setup() { seed_handler "price.py"; }
check() {
  if run_harness price "$HANDLERS/price.py"; then
    pass "the forged total is ignored; the server prices the order from its own catalog. The trust boundary holds."
  else
    fail "make ~/workspace/handlers/price.py compute the total server-side (see failing check above), then run lesson check"
    return 1
  fi
}
