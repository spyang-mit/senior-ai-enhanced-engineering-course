# shellcheck shell=bash disable=SC2034
TASK_TITLE="Pull from a remote (git pull)"
TASK_CAT="Remotes (bonus)"
TASK_BODY="Push sends your work up; PULL brings other people's work down. While
you weren't looking, a 'teammate' — really just another clone of the same local
remote — pushed a new file to origin. Your repo doesn't have it yet.

Bring it in:
  git pull

'git pull' fetches the new commits from origin and merges them into your current
branch. Afterward you'll have a new file, TEAMMATE.txt, and the teammate's commit
in your log."
TASK_TRY="git pull"
TASK_WHY="pull = fetch (download new commits) + merge (integrate them). It's how
you stay in sync with everyone else. Here the 'teammate' is a second local repo,
but against GitHub it's the same command and the same result."
TASK_HINTS=(
  "Just run: git pull"
  "After pulling, 'ls' shows TEAMMATE.txt and 'git log --oneline' shows the teammate's commit on top."
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
  # a teammate (another clone) pushes a new commit to origin
  local tmp; tmp="$(mktemp -d)"
  git clone -q "$HOME/remote.git" "$tmp/tc" 2>/dev/null
  printf 'work from a teammate\n' > "$tmp/tc/TEAMMATE.txt"
  git -C "$tmp/tc" add -A
  git -C "$tmp/tc" commit -q -m "Add teammate's file"
  git -C "$tmp/tc" push -q origin main
  rm -rf "$tmp"
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if [ -f "$REPO/TEAMMATE.txt" ] && [ "$(g rev-list --count main 2>/dev/null || echo 0)" -ge 2 ]; then
    pass "pulled — the teammate's commit (TEAMMATE.txt) is now in your repo. 'git pull' fetched it from origin and merged it in."
  else
    fail "the teammate pushed a change to origin. Bring it into your repo with: git pull"
    return 1
  fi
}
