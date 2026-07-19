# shellcheck shell=bash disable=SC2034
TASK_TITLE="Grab one commit (cherry-pick)"
TASK_CAT="History"
TASK_BODY="Sometimes you want just ONE commit from another branch, not the whole
thing. 'git cherry-pick <hash>' copies a single commit onto your current branch.

There's a branch 'extras' with two commits:
  • 'Add feature A'  (creates featureA.txt)
  • 'Add feature B'  (creates featureB.txt)
You're on main and you want ONLY feature A. First find its commit hash, then
cherry-pick it:
  git log extras --oneline        # shows both commits with their short hashes
  git cherry-pick <hash-of-A>     # paste the hash next to 'Add feature A'

Afterward main should have featureA.txt but NOT featureB.txt."
TASK_TRY="git log extras --oneline"
TASK_WHY="cherry-pick is how you lift a single fix out of a branch — say a bug
fix you need now, without merging a half-finished feature. Every commit has a
hash; cherry-pick replays exactly that one onto where you are."
TASK_HINTS=(
  "git log extras --oneline shows the two commits. Copy the hash beside 'Add feature A', then: git cherry-pick <that-hash>"
  "If you accidentally pick 'Add feature B', run 'lesson next' to reset and pick A instead."
)
setup() {
  repo_init_with_commit
  g checkout -q -b extras
  repo_commit featureA.txt "Add feature A" <<< "AAA"
  repo_commit featureB.txt "Add feature B" <<< "BBB"
  g checkout -q main
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if ! on_branch main; then fail "you should be on main for this — git checkout main"; return 1; fi
  if [ -e "$REPO/featureB.txt" ]; then
    fail "that pulled in feature B too. Run 'lesson next' to reset, then cherry-pick ONLY the 'Add feature A' hash."; return 1
  fi
  if [ -f "$REPO/featureA.txt" ] && g log --format=%s main 2>/dev/null | grep -qxF "Add feature A"; then
    pass "you cherry-picked just 'Add feature A' onto main — featureA.txt is here, featureB.txt is not."
  else
    fail "find the hash (git log extras --oneline) and cherry-pick 'Add feature A': git cherry-pick <hash>"
    return 1
  fi
}
