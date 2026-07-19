# shellcheck shell=bash disable=SC2034
TASK_TITLE="Rebase, then force-push your branch"
TASK_CAT="Remotes (bonus)"
TASK_BODY="This is the situation where you'll actually reach for --force. You have
a feature branch 'my-feature' pushed to origin. Meanwhile main moved on — a
teammate merged something — so your branch is now based on a stale main. The
clean fix: get the latest main and rebase your branch on top of it.

Do the real loop:
  git checkout main
  git pull                       # get the teammate's new commit on main
  git checkout my-feature
  git rebase main                # replay your work on top of the updated main
  git push                       # REJECTED: ! [rejected] ... (non-fast-forward)
  git push --force               # override — replace origin's copy of YOUR branch

Why the rejection? Rebasing REWRITES your branch's commits (new hashes). origin
still has the old ones, so a normal push isn't a fast-forward. Because you
deliberately rewrote your own branch, --force is correct here.

⚠  Safe because my-feature is YOUR branch. NEVER force-push a shared branch like
main. Better habit: 'git push --force-with-lease', which refuses if someone else
pushed to your branch meanwhile."
TASK_TRY="git checkout main"
TASK_WHY="Rebase-then-force-push is the single most common reason to force-push:
keep your branch current by replaying it on the latest main, then update the
branch you already pushed. Rebasing changes commit hashes, so only --force (or
--force-with-lease) can move the remote branch to match."
TASK_HINTS=(
  "Update main (git checkout main; git pull), rebase your branch (git checkout my-feature; git rebase main), then git push (rejected) and git push --force."
  "Prefer 'git push --force-with-lease' in real projects — it won't clobber work someone else pushed to your branch."
)
setup() {
  repo_reset
  rm -rf "$HOME/remote.git"
  git init -q --bare -b main "$HOME/remote.git"
  g init -q -b main
  g remote add origin "$HOME/remote.git"
  repo_commit README.md "Initial commit" <<< "readme"
  g push -q -u origin main
  g checkout -q -b my-feature
  repo_commit feature.txt "Add my feature" <<< "feature work"
  g push -q -u origin my-feature
  g checkout -q main
  # a teammate advances main on origin (local main is now behind)
  local tmp; tmp="$(mktemp -d)"
  git clone -q "$HOME/remote.git" "$tmp/tc" 2>/dev/null
  printf 'shared change\n' > "$tmp/tc/main.txt"
  git -C "$tmp/tc" add -A
  git -C "$tmp/tc" commit -q -m "Teammate: update main"
  git -C "$tmp/tc" push -q origin main
  rm -rf "$tmp"
  g checkout -q my-feature
}
check() {
  local remote="$HOME/remote.git"
  [ -d "$remote" ] || { fail "the remote is missing — run 'lesson next' to reset this task."; return 1; }
  if rebase_in_progress; then fail "finish the rebase (git rebase main), then push --force."; return 1; fi
  if ! on_branch my-feature; then fail "end up on your feature branch: git checkout my-feature"; return 1; fi
  if [ ! -f "$REPO/feature.txt" ]; then fail "your feature commit is missing — 'lesson next' to reset and try again."; return 1; fi
  if [ ! -f "$REPO/main.txt" ]; then
    fail "your branch doesn't include the teammate's main update yet. Update main and rebase onto it: git checkout main; git pull; git checkout my-feature; git rebase main"; return 1
  fi
  if [ -n "$(g rev-list --merges my-feature 2>/dev/null)" ]; then
    fail "that looks like you MERGED main in — this task wants a REBASE (git rebase main) for a linear history, which is what makes the force-push necessary."; return 1
  fi
  local rt lt
  rt="$(git -C "$remote" rev-parse my-feature 2>/dev/null)"
  lt="$(g rev-parse my-feature 2>/dev/null)"
  if [ "$rt" = "$lt" ]; then
    pass "you rebased my-feature onto the updated main and force-pushed it — the everyday reason for --force. Rebasing rewrote your commits, so a plain push was rejected; forcing it updates your branch on origin."
  else
    fail "your rebased branch differs from origin's copy, so a normal 'git push' is rejected. Update origin with: git push --force"; return 1
  fi
}
