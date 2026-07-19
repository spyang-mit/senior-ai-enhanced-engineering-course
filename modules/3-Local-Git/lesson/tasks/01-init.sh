# shellcheck shell=bash disable=SC2034
TASK_TITLE="Start a repository (git init)"
TASK_CAT="Basics"
TASK_BODY="git tracks the history of a project so you can see what changed, go
back, and work on things in parallel without losing anything. It does this
inside a normal folder by creating a hidden '.git' directory.

Your playground has a couple of files (app.py, notes.txt) but git isn't
watching yet. Turn this folder into a repository, then ask git what it sees:
  git init      create the repo (the hidden .git folder)
  git status    show the state — you'll see the files as 'untracked'

'untracked' means git can see the files exist but isn't recording their history
yet. You'll fix that next."
TASK_TRY="git init"
TASK_WHY="A repo is just a folder plus a .git directory holding its whole
history. 'git status' is the command you'll run more than any other — it always
tells you where you stand: what's changed, what's staged, what branch you're on."
TASK_HINTS=(
  "Run: git init   then   git status"
  "git init prints something like 'Initialized empty Git repository'. After that, git status lists app.py and notes.txt as untracked."
)
setup() {
  repo_reset
  printf 'print("hello")\n' > "$REPO/app.py"
  printf 'project notes\n' > "$REPO/notes.txt"
}
check() {
  if is_repo; then
    pass "this folder is now a git repository (.git exists). 'git status' shows app.py and notes.txt as untracked."
  else
    fail "run 'git init' here to create the repository"
    return 1
  fi
}
