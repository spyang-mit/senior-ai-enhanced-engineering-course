# shellcheck shell=bash disable=SC2034
TASK_TITLE="Push a branch to a remote (git push)"
TASK_CAT="Remotes (bonus)"
TASK_BODY="You've finished the core local workflow. This short bonus arc shows
the mechanics of sharing work through a REMOTE — another copy of the repo people
push to and pull from. Normally that's GitHub; here we fake it with a second
LOCAL repository so you can feel how it works. Contrived, but 'git push' behaves
the same against a real server.

Important real-world habit: you almost never push straight to 'main'. On a real
remote, main is PROTECTED — direct pushes are rejected. Instead you push a
FEATURE BRANCH and open a pull request for review. Our local remote has no
protection, but we'll model the real workflow: branch, commit, push the branch.

Your repo is connected to a remote called 'origin' (main is already there):
  git remote -v                          # origin -> ~/remote.git
  git checkout -b add-greeting
  echo 'greeting: hello' >> README.md
  git commit -a -m \"Add a greeting line\"
  git push -u origin add-greeting

The '-u' links your local branch to the remote one, so later 'git push' and
'git pull' know where to go."
TASK_TRY="git checkout -b add-greeting"
TASK_WHY="Real remotes protect main so every change is reviewed before it lands.
The unit you share is a branch: push it, open a PR, get it merged — you rarely
push main yourself. 'git push -u origin <branch>' publishes your branch and sets
its upstream."
TASK_HINTS=(
  "git checkout -b add-greeting → make a commit → git push -u origin add-greeting"
  "Push the BRANCH, not main — the command ends with 'origin add-greeting'."
)
setup() {
  repo_reset
  rm -rf "$HOME/remote.git"
  git init -q --bare -b main "$HOME/remote.git"
  g init -q -b main
  g remote add origin "$HOME/remote.git"
  repo_commit README.md "Initial commit" <<'EOF'
project readme
EOF
  g push -q -u origin main
}
check() {
  local remote="$HOME/remote.git"
  [ -d "$remote" ] || { fail "the remote is missing — run 'lesson next' to reset this task."; return 1; }
  if ! git -C "$remote" show-ref --verify --quiet refs/heads/add-greeting; then
    fail "push a feature branch: git checkout -b add-greeting, commit, then git push -u origin add-greeting"; return 1
  fi
  local rb lb
  rb="$(git -C "$remote" rev-parse add-greeting 2>/dev/null)"
  lb="$(g rev-parse add-greeting 2>/dev/null)"
  if [ -n "$lb" ] && [ "$rb" = "$lb" ] && [ "$(g rev-list --count main..add-greeting 2>/dev/null || echo 0)" -ge 1 ]; then
    pass "pushed the 'add-greeting' branch to origin (main untouched). That's the real workflow — branch, push, open a PR — never straight to main."
  else
    fail "commit on add-greeting first, then push it: git push -u origin add-greeting"; return 1
  fi
}
