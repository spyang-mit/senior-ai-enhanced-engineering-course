# shellcheck shell=bash disable=SC2034
TASK_TITLE="Move into a directory"
TASK_CAT="Navigation"
TASK_BODY="Everything starts with knowing where you are and moving around.
  pwd            print the directory you're in ('print working directory')
  cd somedir     move into a child directory
  cd path/to/x   move several levels at once

Move into the web app's source folder: projects/webapp/src"
TASK_TRY="cd ~/playground/projects/webapp/src"
TASK_WHY="The '~' is a shortcut for your home directory, so this works no
matter where you currently are. Absolute-ish paths like this are safer than
guessing relative hops."
TASK_HINTS=(
  "pwd tells you where you are now; cd moves you."
  "Run: cd ~/playground/projects/webapp/src"
)
check() {
  if cwd_is "$HOME/playground/projects/webapp/src"; then
    pass "you're in $(pwd) — nicely navigated."
  else
    fail "you're in $(pwd); the target is ~/playground/projects/webapp/src"
    return 1
  fi
}
