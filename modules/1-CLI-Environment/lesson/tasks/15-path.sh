# shellcheck shell=bash disable=SC2034
TASK_TITLE="Put a directory on your PATH"
TASK_CAT="Environment variables"
TASK_BODY="There's a ready-made command in ~/playground/bin called 'greet',
but typing 'greet' right now gives 'command not found' — because that folder
isn't on your PATH.

Add it to the FRONT of PATH so the shell can find it:
  export PATH=\"\$HOME/playground/bin:\$PATH\"
Then just run:  greet"
TASK_TRY="export PATH=\"\$HOME/playground/bin:\$PATH\""
TASK_WHY="Order matters: the shell uses the FIRST match it finds walking PATH
left to right. Putting a directory first lets it shadow a system command —
handy, but also how a malicious dir on PATH can hijack 'ls'. Never add '.'
(the current dir) to PATH."
TASK_HINTS=(
  "Prepend the bin dir, keeping the old PATH after the colon."
  "Run: export PATH=\"\$HOME/playground/bin:\$PATH\"  then: greet"
)
check() {
  if path_contains "$HOME/playground/bin"; then
    pass "~/playground/bin is on your PATH — 'greet' resolves now. Try it!"
  else
    fail "I don't see ~/playground/bin in PATH yet"; return 1
  fi
}
