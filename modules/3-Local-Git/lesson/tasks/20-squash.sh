# shellcheck shell=bash disable=SC2034
TASK_TITLE="Squash commits (interactive rebase)"
TASK_CAT="History"
TASK_BODY="Working on a feature you usually leave a messy trail: 'wip', 'more
work', 'fix typo'. Before sharing, you SQUASH those into one clean commit. The
tool is INTERACTIVE rebase.

This branch has three 'wip' commits on top of the initial one. Combine them:
  git rebase -i HEAD~3
('HEAD' means the current commit, and ~3 means '3 back'. Handy shorthand: '@'
is an alias for HEAD, so 'git rebase -i @~3' does the same with fewer keystrokes.
HEAD is more common in docs and teams; use whichever you like.)

An editor (vim) opens with a to-do list — one line per commit, OLDEST at the
top, each starting with 'pick':
  pick 1111111 wip: start the feature
  pick 2222222 wip: more work
  pick 3333333 wip: fix a typo
Leave the FIRST as 'pick'. Change the word 'pick' to 's' (short for 'squash') on
the other two, so they fold INTO the commit above:
  pick 1111111 wip: start the feature
  s    2222222 wip: more work
  s    3333333 wip: fix a typo
Save with :wq. A SECOND editor then opens to write the combined message — type
one clean line like 'Add the feature', then :wq. Three commits become one."
TASK_TRY="git rebase -i HEAD~3"
TASK_WHY="Squashing turns a noisy work-in-progress trail into a single readable
commit that says what you actually did. 'pick' keeps a commit as-is; 'squash'
(or 's') merges it into the one above. It's the same replay-your-commits idea as
plain rebase, but here you edit each step."
TASK_HINTS=(
  "git rebase -i HEAD~3 → in vim, change 'pick' to 's' on the 2nd and 3rd lines (leave the 1st as pick), :wq → write one message in the second editor, :wq."
  "Change a word in vim with cw: put the cursor on 'pick', press cw, type s, Esc. Stuck mid-rebase? 'git rebase --abort', then 'lesson next' to reset."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit README.md "Initial commit"      <<< "readme"
  repo_commit a.txt "wip: start the feature"   <<< "a"
  repo_commit b.txt "wip: more work"           <<< "b"
  repo_commit c.txt "wip: fix a typo"          <<< "c"
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if rebase_in_progress; then fail "the interactive rebase is still open — set the lower commits to 's', save, write the combined message, and it will finish."; return 1; fi
  local n; n="$(commit_count)"
  if [ "$n" -gt 2 ]; then fail "still $n commits — squash the three 'wip' commits into one with: git rebase -i HEAD~3 (pick the first, 's' the other two)."; return 1; fi
  if [ "$n" -lt 2 ]; then fail "you squashed too much — you should keep the initial commit plus ONE squashed commit (2 total). 'lesson next' resets it."; return 1; fi
  if [ -f "$REPO/a.txt" ] && [ -f "$REPO/b.txt" ] && [ -f "$REPO/c.txt" ] && working_clean; then
    pass "three messy 'wip' commits squashed into one — and all their changes (a.txt, b.txt, c.txt) are still here. Clean history."
  else
    fail "the squash must keep all the changes (a.txt, b.txt, c.txt) together in the one commit"
    return 1
  fi
}
