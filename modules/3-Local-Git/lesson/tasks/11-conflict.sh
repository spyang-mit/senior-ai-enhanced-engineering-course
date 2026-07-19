# shellcheck shell=bash disable=SC2034
TASK_TITLE="Hit a merge conflict (merge #2)"
TASK_CAT="Conflicts"
TASK_BODY="main now has version = 2.0 (blue is merged). Branch 'green' set the
same line to version = 3.0, based on the original 1.0. Both sides changed the
SAME line — git can't guess which you want. Try the merge and watch it stop:
  git merge green

git prints 'CONFLICT (content): Merge conflict in config.txt' and pauses. Two
commands tell you different things:
  git status        lists WHICH files are stuck — config.txt under
                    'Unmerged paths' as 'both modified'
  cat config.txt    shows what git did to the FILE itself: it wrote both
                    versions in, wrapped in conflict markers:
                        <<<<<<< HEAD
                        version = 2.0
                        =======
                        version = 3.0
                        >>>>>>> green

So 'git status' points you at the file; opening the file shows the markers you'd
edit to resolve it. DON'T fix it yet — the next task shows the safe way to back
out. Just trigger the conflict here."
TASK_TRY="git merge green"
TASK_WHY="A conflict isn't an error you did wrong — it's git honestly saying
'two changes disagree; you decide.' The <<<<<<< ======= >>>>>>> markers wrap
'my side' and 'their side' so you can choose. Learning to stay calm here is the
whole point of this arc."
TASK_HINTS=(
  "Run: git merge green  — git will say 'CONFLICT (content): Merge conflict in config.txt'."
  "'git status' names the stuck file; 'cat config.txt' shows the <<<<<<< ======= >>>>>>> markers inside it. Leave it conflicted; the next task handles it."
)
setup() {
  repo_reset
  g init -q -b main
  repo_commit config.txt "Add config" <<'EOF'
name = app
version = 1.0
port = 8080
EOF
  g checkout -q -b green
  repo_commit config.txt "Set version to 3.0 (green)" <<'EOF'
name = app
version = 3.0
port = 8080
EOF
  g checkout -q main
  repo_commit config.txt "Set version to 2.0 (blue, merged)" <<'EOF'
name = app
version = 2.0
port = 8080
EOF
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if merge_in_progress && has_conflicts && has_conflict_markers "$REPO/config.txt"; then
    pass "conflict triggered — config.txt has <<<<<<< ======= >>>>>>> markers and git is mid-merge. Exactly right; don't resolve it yet."
  else
    fail "start the conflicting merge: git merge green (you should be on main)"
    return 1
  fi
}
