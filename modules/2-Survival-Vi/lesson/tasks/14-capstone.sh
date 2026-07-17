# shellcheck shell=bash disable=SC2034
TASK_TITLE="Capstone: fix the config"
TASK_CAT="Capstone"
TASK_BODY="Put it all together on one messy file. deploy.conf starts as:
  # deploy config
  naem = webapp
  env = prodction
  DEBUG_JUNK_LINE
  port = 8O80
Fix everything so it becomes:
  # deploy config
  name = webapp
  env = production
  port = 8080
That means: fix 'naem' -> 'name', fix 'prodction' -> 'production', DELETE the
'DEBUG_JUNK_LINE' line entirely, and fix the port (that's a letter O that should
be a zero: 8O80 -> 8080). Use whatever you like — cw, r, dd, x. Then :wq.
  vim deploy.conf"
TASK_TRY="vim deploy.conf"
TASK_WHY="This is a normal day in vi: a couple of typos, a junk line to drop, one
sneaky wrong character. Nothing here is a command you haven't already used —
you're fluent enough now to just fix a file and move on."
TASK_HINTS=(
  "naem→name and prodction→production are cw jobs. Drop the junk line with dd. The port has a letter O where a 0 belongs — land on it and press r0."
  "Target, exactly: '# deploy config' / 'name = webapp' / 'env = production' / 'port = 8080'."
)
setup() {
  local f="$HOME/playground/deploy.conf"
  [ -e "$f" ] || printf '# deploy config\nnaem = webapp\nenv = prodction\nDEBUG_JUNK_LINE\nport = 8O80\n' > "$f"
}
check() {
  local f="$HOME/playground/deploy.conf"
  [ -f "$f" ] || { fail "deploy.conf is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
# deploy config
name = webapp
env = production
port = 8080
EOF
  then
    pass "clean config: typos fixed, junk line gone, port corrected. You're dangerous in vi now. 🎉"
  else
    fail "not there yet — compare against the target in the task"
    show_diff "$f" <<'EOF'
# deploy config
name = webapp
env = production
port = 8080
EOF
    return 1
  fi
}
