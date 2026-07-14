# shellcheck shell=bash disable=SC2034
TASK_TITLE="Come back up"
TASK_CAT="Navigation"
TASK_BODY="Going up is just as important as going down. '..' means 'the parent
directory':
  cd ..          up one level
  cd ../..       up two levels
  cd ../../..    up three levels

A couple more shortcuts:
  cd             with NO argument, jumps to your home directory. Careful: your
                 home is /home/dev — that's one level ABOVE playground.
  cd -           jumps back to the directory you were just in (a handy toggle)

You're down in projects/webapp/src. Climb back to your playground root."
TASK_TRY="cd ../../..          # or the shortcut: cd ~/playground"
TASK_WHY="Relative moves ('..') are how you actually get around day to day.
'cd ~/playground' is the absolute shortcut when you want to jump straight
there from anywhere — good to know, but notice you didn't need it to move
around locally."
TASK_HINTS=(
  "src -> webapp -> projects -> playground is three levels up: cd ../../.."
  "Or just jump: cd ~/playground"
)
check() {
  if cwd_is "$HOME/playground"; then
    pass "back at $(pwd). You can now navigate up, down, and sideways."
  else
    fail "you're in $(pwd); climb back to ~/playground (try: cd ../../..)"
    return 1
  fi
}
