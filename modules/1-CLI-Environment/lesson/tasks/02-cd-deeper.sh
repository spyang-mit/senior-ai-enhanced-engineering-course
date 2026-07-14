# shellcheck shell=bash disable=SC2034
TASK_TITLE="Go deeper"
TASK_CAT="Navigation"
TASK_BODY="You're in 'projects' now. Run 'ls' — there's a 'webapp' folder, and
inside it a 'src' folder. You can hop one level at a time, or several at once:
  cd webapp        then    cd src
  cd webapp/src    both levels in one go

Get down into webapp/src. Use TAB as you go: 'cd we<TAB>' then 'sr<TAB>'."
TASK_TRY="cd webapp/src        # or step through: cd webapp  then  cd src"
TASK_WHY="Notice you're still not typing a long path from the root. You look
around with 'ls', see what's directly beneath you, and move into it.
Tab-completion turns a long path into a few keystrokes."
TASK_HINTS=(
  "From projects: cd into webapp, then into src (or cd webapp/src)."
  "Run: cd webapp/src"
)
check() {
  if cwd_is "$HOME/playground/projects/webapp/src"; then
    pass "you're in $(pwd) — nicely done, that's three levels deep."
  else
    fail "you're in $(pwd); aim for projects/webapp/src"
    return 1
  fi
}
