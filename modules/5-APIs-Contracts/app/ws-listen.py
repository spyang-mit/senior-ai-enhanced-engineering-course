#!/usr/bin/env python3
"""
A tiny websocket client for the polling-vs-websocket task.

Run it (in the container shell):  python3 ~/workspace/ws-listen.py
It connects to the demo websocket at ws://localhost:8081 and prints each order-
status update the SERVER pushes -- no polling loop on your side. Compare that to
running, over and over:   curl -s localhost:8080/orders/1 | jq .status

Ctrl-C to stop.
"""
import asyncio
import sys

try:
    import websockets
except Exception:
    print("(websockets library not available; the concept still holds -- see the task)")
    sys.exit(0)

URL = "ws://localhost:8081"


async def main():
    try:
        async with websockets.connect(URL) as ws:
            print(f"connected to {URL} -- waiting for pushes (Ctrl-C to stop)\n")
            async for message in ws:
                print("push:", message)
    except Exception as e:
        print(f"could not connect to {URL}: {e}")
        print("Is the demo websocket running? (It starts with the sandbox.)")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nstopped.")
