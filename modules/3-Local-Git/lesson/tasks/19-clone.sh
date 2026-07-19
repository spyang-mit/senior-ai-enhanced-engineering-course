# shellcheck shell=bash disable=SC2034
TASK_TITLE="Clone a repo (git clone)"
TASK_CAT="Remotes (bonus)"
TASK_BODY="How do you GET a repo that already exists — a project on GitHub, or
the shared remote here? You clone it. 'git clone' copies the whole repo (all its
history) into a new folder and automatically sets up 'origin' pointing back to
where it came from.

There's a bare remote at ~/remote.git with some history. Clone it into a folder
called 'myproject', then look around:
  git clone ~/remote.git myproject
  cd myproject
  git log --oneline      # the full history came along
  git remote -v          # origin already points at ~/remote.git

This is exactly how you'd start from a GitHub repo: git clone <url> <folder>.

When you're done exploring, step back out to the playground so the next task
starts fresh:
  cd ~/playground"
TASK_TRY="git clone ~/remote.git myproject"
TASK_WHY="clone is usually step one on any project — it downloads the repo and
wires up origin so push/pull just work. Everything you learned with
init/add/commit/branch now applies to a repo you got from someone else."
TASK_HINTS=(
  "Run: git clone ~/remote.git myproject   (this creates a new folder called myproject)."
  "Then: cd myproject, and try git log --oneline and git remote -v."
)
setup() {
  repo_reset
  rm -rf "$HOME/remote.git"
  git init -q --bare -b main "$HOME/remote.git"
  # seed the remote with some history via a throwaway clone
  local tmp; tmp="$(mktemp -d)"
  git clone -q "$HOME/remote.git" "$tmp/seed" 2>/dev/null
  printf 'hello\n'        > "$tmp/seed/README.md"
  printf 'print("hi")\n'  > "$tmp/seed/app.py"
  git -C "$tmp/seed" add -A
  git -C "$tmp/seed" commit -q -m "Initial project"
  git -C "$tmp/seed" push -q origin main
  rm -rf "$tmp"
}
check() {
  local c="$REPO/myproject"
  if [ ! -d "$c/.git" ]; then fail "clone the remote into a folder: git clone ~/remote.git myproject"; return 1; fi
  if git -C "$c" remote get-url origin >/dev/null 2>&1 && [ -f "$c/README.md" ] && [ -f "$c/app.py" ]; then
    pass "cloned — 'myproject' is a full working copy of the remote, history and all, with 'origin' wired back to it. That's how every project starts."
  else
    fail "make a working clone named myproject: git clone ~/remote.git myproject"
    return 1
  fi
}
