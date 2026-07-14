# shellcheck shell=bash disable=SC2034
TASK_TITLE="Jump back home"
TASK_CAT="Navigation"
TASK_BODY="A few cd shortcuts you'll use constantly:
  cd            with no argument, goes to your home directory
  cd ~/x        goes to x under your home
  cd ..         goes up one level (to the parent)
  cd -          goes back to the directory you were just in

Get to your playground root: ~/playground"
TASK_TRY="cd ~/playground"
TASK_WHY="'cd -' is the toggle you'll reach for most — it flips between the
last two directories, like alt-tab for the shell."
TASK_HINTS=(
  "cd with a path, or hop up with cd .. a couple times."
  "Run: cd ~/playground"
)
check() {
  if cwd_is "$HOME/playground"; then
    pass "back home base: $(pwd)"
  else
    fail "you're in $(pwd); head to ~/playground"
    return 1
  fi
}
