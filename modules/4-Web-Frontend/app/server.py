#!/usr/bin/env python3
"""Module 4 contacts API — Python standard library only.

Implements the CONTRACT in contacts-api.yaml: CRUD over /contacts with bearer
auth on writes, validation, filtering, a slow path and a failing path (for
loading/error states), a redirect, and permissive CORS so a frontend served
from anywhere can call it. Every request is appended to an access log so the
lesson can verify which endpoints a frontend actually exercised.
"""
import json, os, re, threading, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

APP_DIR    = os.environ.get("APP_DIR", "/opt/app")
ACCESS_LOG = os.environ.get("ACCESS_LOG", "/tmp/access.log")
TOKEN      = "let-me-in"
PORT       = int(os.environ.get("PORT", "8080"))

_lock = threading.Lock()
contacts = [
    {"id": 1, "firstName": "Ada",   "lastName": "Lovelace", "phone": "555-0100"},
    {"id": 2, "firstName": "Alan",  "lastName": "Turing",   "phone": "555-0142"},
    {"id": 3, "firstName": "Grace", "lastName": "Hopper",   "phone": "555-0199"},
]
_next_id = 4


def log(method, path, status):
    try:
        with open(ACCESS_LOG, "a") as f:
            f.write(f"{method} {path} {status}\n")
    except OSError:
        pass


class Handler(BaseHTTPRequestHandler):
    server_version = "ContactsAPI/1.0"

    def log_message(self, *a):  # silence the default stderr logging
        pass

    # --- helpers ------------------------------------------------------------
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")

    def _path(self):
        return self.path.split("?", 1)[0]

    def _query(self):
        if "?" not in self.path:
            return {}
        q = {}
        for part in self.path.split("?", 1)[1].split("&"):
            if "=" in part:
                k, v = part.split("=", 1)
                q[k] = v
        return q

    def _send_json(self, status, obj):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self._cors()
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)
        log(self.command, self._path(), status)

    def _send_status(self, status):
        self.send_response(status)
        self.send_header("Content-Length", "0")
        self._cors()
        self.end_headers()
        log(self.command, self._path(), status)

    def _send_file(self, path, ctype):
        try:
            with open(path, "rb") as f:
                body = f.read()
        except OSError:
            return self._send_json(404, {"error": "not found"})
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self._cors()
        self.end_headers()
        self.wfile.write(body)
        log(self.command, self._path(), 200)

    def _authed(self):
        return self.headers.get("Authorization", "") == f"Bearer {TOKEN}"

    def _body(self):
        n = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(n) if n else b""
        try:
            return json.loads(raw or b"{}")
        except json.JSONDecodeError:
            return None

    def _contact_id(self):
        m = re.fullmatch(r"/contacts/(\d+)", self._path())
        return int(m.group(1)) if m else None

    # --- verbs --------------------------------------------------------------
    def do_OPTIONS(self):
        self._send_status(204)

    def do_GET(self):
        p, q = self._path(), self._query()
        if p in ("/", "/index.html"):
            return self._send_file(os.path.join(APP_DIR, "index.html"), "text/html; charset=utf-8")
        if p in ("/openapi.yaml", "/contacts-api.yaml"):
            return self._send_file(os.path.join(APP_DIR, "contacts-api.yaml"), "application/yaml")
        if p == "/old-contacts":
            self.send_response(301)
            self.send_header("Location", "/contacts")
            self.send_header("Content-Length", "0")
            self._cors()
            self.end_headers()
            return log("GET", p, 301)
        if p == "/contacts":
            if q.get("fail") == "1":
                return self._send_json(500, {"error": "simulated server error"})
            if q.get("delay"):
                try: time.sleep(min(float(q["delay"]), 5))
                except ValueError: pass
            term = q.get("q", "").lower().replace("+", " ").replace("%20", " ")
            with _lock:
                items = [c for c in contacts
                         if term in (c["firstName"] + " " + c["lastName"]).lower()]
            return self._send_json(200, items)
        cid = self._contact_id()
        if cid is not None:
            with _lock:
                c = next((c for c in contacts if c["id"] == cid), None)
            return self._send_json(200, c) if c else self._send_json(404, {"error": "no such contact"})
        return self._send_json(404, {"error": "not found"})

    def _validate(self, data):
        if data is None:
            return "body must be valid JSON"
        for field in ("firstName", "lastName", "phone"):
            if not str(data.get(field, "")).strip():
                return f"{field} is required"
        return None

    def do_POST(self):
        global _next_id
        if self._path() != "/contacts":
            return self._send_json(404, {"error": "not found"})
        if not self._authed():
            return self._send_json(401, {"error": "missing or invalid bearer token"})
        data = self._body()
        err = self._validate(data)
        if err:
            return self._send_json(400, {"error": err})
        with _lock:
            c = {"id": _next_id, "firstName": data["firstName"],
                 "lastName": data["lastName"], "phone": data["phone"]}
            _next_id += 1
            contacts.append(c)
        return self._send_json(201, c)

    def do_PUT(self):
        cid = self._contact_id()
        if cid is None:
            return self._send_json(404, {"error": "not found"})
        if not self._authed():
            return self._send_json(401, {"error": "missing or invalid bearer token"})
        data = self._body()
        err = self._validate(data)
        if err:
            return self._send_json(400, {"error": err})
        with _lock:
            c = next((c for c in contacts if c["id"] == cid), None)
            if not c:
                return self._send_json(404, {"error": "no such contact"})
            c.update(firstName=data["firstName"], lastName=data["lastName"], phone=data["phone"])
        return self._send_json(200, c)

    def do_DELETE(self):
        global contacts
        cid = self._contact_id()
        if cid is None:
            return self._send_json(404, {"error": "not found"})
        if not self._authed():
            return self._send_json(401, {"error": "missing or invalid bearer token"})
        with _lock:
            exists = any(c["id"] == cid for c in contacts)
            if not exists:
                return self._send_json(404, {"error": "no such contact"})
            contacts = [c for c in contacts if c["id"] != cid]
        return self._send_status(204)


if __name__ == "__main__":
    open(ACCESS_LOG, "a").close()  # ensure the log file exists
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
