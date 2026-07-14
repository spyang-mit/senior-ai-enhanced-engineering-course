# shellcheck shell=bash disable=SC2034
TASK_TITLE="Step into a directory"
TASK_CAT="Navigation"
TASK_BODY="First, get your bearings:
  pwd     print where you are  (you're in ~/playground right now)
  ls      list what's here

You'll see a 'projects' folder. Step into it — from where you already are,
you just name it, no long path needed:
  cd projects

** Tab-completion (learn this now, use it forever) **
Instead of typing 'projects', type 'cd pr' and press the TAB key — the shell
finishes the name for you. It's faster and it prevents typos. Try it."
TASK_TRY="cd projects        # or: cd pr<TAB>"
TASK_WHY="Humans navigate RELATIVE to where they are — you saw 'projects' in
the listing, so you just 'cd projects'. You rarely type a full path from the
root; you look, then hop. Tab-completion makes that instant."
TASK_HINTS=(
  "Run 'ls' to see 'projects', then cd into it by name."
  "Run: cd projects   (or type 'cd pr' and hit TAB)"
)
check() {
  if cwd_is "$HOME/playground/projects"; then
    pass "you're in $(pwd) — stepped in with a relative hop."
  else
    fail "you're in $(pwd); from ~/playground, try: cd projects"
    return 1
  fi
}
