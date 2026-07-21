#!/usr/bin/env python3
"""
Demo websocket server for Module 5's polling-vs-websocket task, on :8081.

It PUSHES a synthetic order-status update every few seconds to every connected
client. There is no request/response here -- the server speaks first and keeps
speaking. Contrast with polling the REST API, where the client must ask again
and again. Uses the `websockets` library; if it isn't installed the sandbox
still works (the task is conceptual + a quiz).
"""
import asyncio
import json
import sys

try:
    import websockets
except Exception:
    print("websockets library not installed; ws demo disabled", file=sys.stderr)
    sys.exit(0)

CYCLE = ["pending", "paid", "shipped"]


async def push(ws):
    i = 0
    try:
        while True:
            msg = json.dumps({"orderId": 1, "status": CYCLE[i % len(CYCLE)]})
            await ws.send(msg)
            i += 1
            await asyncio.sleep(3)
    except Exception:
        return


async def main():
    async with websockets.serve(push, "0.0.0.0", 8081):
        print("demo websocket on :8081")
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
