# shellcheck shell=bash disable=SC2034
TASK_TITLE="Put a directory on your PATH"
TASK_CAT="Environment variables"
TASK_BODY="There's a ready-made command in the bin/ folder called 'greet', but
typing 'greet' gives 'command not found' — its folder isn't on your PATH yet.

To fix that you'll build a new value for PATH, so first get comfortable
REFERENCING a variable: put a '\$' in front of its name and the shell replaces
it with the value. Try these and watch the output:
  echo \$HOME              # your home directory, e.g. /home/dev
  echo \"\$HOME \$PATH\"       # both at once — see what PATH currently holds

Notice \$PATH is already a colon-separated list of directories. To ADD your
folder without losing the existing entries, you build a NEW value: your
directory, then a colon, then the old \$PATH — like  \"/some/dir:\$PATH\".

Your task: put the bin/ folder (its absolute path is \$HOME/playground/bin) at
the FRONT of PATH, so the shell finds 'greet'. Then run 'greet' to prove it."
TASK_TRY=""
TASK_WHY="This is the one place we DON'T use a relative path: PATH entries must
be absolute, because the shell searches them from wherever you happen to be
standing. Order matters too — the shell uses the FIRST match walking PATH left
to right, which is how a bad directory on PATH can hijack 'ls'. Never add '.'
(the current dir) to PATH."
TASK_HINTS=(
  "Build it: your directory first, then a colon, then \$PATH — and use 'export' so it sticks. e.g. export PATH=\"/some/dir:\$PATH\""
  "Run: export PATH=\"\$HOME/playground/bin:\$PATH\"   then: greet"
)
check() {
  if path_contains "$HOME/playground/bin"; then
    pass "~/playground/bin is on your PATH — 'greet' resolves now. Try it!"
  else
    fail "I don't see ~/playground/bin in PATH yet"; return 1
  fi
}
