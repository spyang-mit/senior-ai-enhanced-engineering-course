# shellcheck shell=bash disable=SC2034
TASK_TITLE="Anatomy of a request & response"
TASK_CAT="HTTP with curl"
TASK_BODY="You've made requests and read responses. Now see what actually crosses
the wire. When you run curl, you OPEN A CONNECTION to the server at a host and
port, then send it a request. 'curl -v' (verbose) shows BOTH sides:
  curl -s -v http://localhost:8080/contacts

Read the output by its line prefixes:
  *   connection notes — curl opening a connection to 127.0.0.1 on port 8080
  >   the REQUEST curl SENT, line by line:
        GET /contacts HTTP/1.1     <- method, ENDPOINT path, HTTP version
        Host: localhost:8080       <- request headers (metadata you send)
        User-Agent: curl/8.x
        Accept: */*
        (then a blank line, which ends the request)
  <   the RESPONSE the server sent back:
        HTTP/1.0 200 OK            <- status line
        Content-Type: ...          <- response headers
        (then a blank line, which ends the headers)
      ...and then the body — the JSON.

'/contacts' is an ENDPOINT: a specific path on the server you can call. Every
HTTP message has the same shape — a first line, then headers, then a BLANK LINE,
then an optional body. That blank line is a bare carriage-return + line-feed,
written \r\n\r\n; it's how the receiver knows the headers ended and the body
begins. See the real bytes (^M is the \r, the $ marks the \n line end):
  curl -s -i http://localhost:8080/contacts | cat -A
The lone  ^M$  line is that separator; the JSON body follows it.

When you've found the blank line between headers and body, run 'lesson check'."
TASK_TRY="curl -s -v http://localhost:8080/contacts"
TASK_WHY="This is what 'making an HTTP call' really is: open a connection, send a
request line plus headers, get back a status line plus headers plus body, split
by one blank line. Every API call, every fetch(), every page load is this exact
exchange — once you can read it, HTTP stops being a black box."
TASK_HINTS=(
  "In 'curl -v', lines starting with > are what you SENT; lines with < are what came BACK. Each side ends with an empty line."
  "Run  curl -s -i http://localhost:8080/contacts | cat -A  — the single  ^M$  line (a bare CRLF) is the \r\n\r\n gap before the body."
)
TASK_QUIZ="In every HTTP message, what separates the headers from the body?"
TASK_QUIZ_OPTIONS=(
  "A single comma between them"
  'A blank line — a bare CRLF (\r\n\r\n)'
  "Nothing; the body simply follows immediately"
  "An opening <body> tag"
)
TASK_QUIZ_ANSWER=2
TASK_QUIZ_EXPLAIN='A blank line — a bare \r\n\r\n. Headers end, one empty line, then the body begins.'
