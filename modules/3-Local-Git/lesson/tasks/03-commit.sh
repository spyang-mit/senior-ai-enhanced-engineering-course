# shellcheck shell=bash disable=SC2034
TASK_TITLE="Make a commit (git commit)"
TASK_CAT="Basics"
TASK_BODY="A COMMIT is a permanent snapshot of everything in the staging area,
with a message describing WHY. notes.txt is already staged, so let's commit it.

Run:
  git commit
This opens a text editor for the commit message — and that editor is vim (this
is where Module 2 pays off!). At the top, type a short message like:
  Add project notes
then save and quit with Esc, :wq. git records the commit.

(Lines starting with # in that editor are comments and are ignored. If you save
an empty message, git cancels the commit — so type a real line.)"
TASK_TRY="git commit"
TASK_WHY="Each commit is a labeled point you can return to. The message matters:
future-you (and teammates) read it to understand WHY a change happened.
Shortcut for later: 'git commit -m \"message\"' skips the editor."
TASK_HINTS=(
  "Run: git commit — then in vim, type a message on the first line, press Esc, and type :wq to save and quit."
  "Prefer to skip the editor? 'git commit -m \"Add project notes\"' does it in one line."
)
setup() {
  repo_reset
  g init -q -b main
  printf 'buy milk\nwalk the dog\n' > "$REPO/notes.txt"
  g add -A
}
check() {
  if ! is_repo; then fail "no repo here — run 'lesson next' to reset this task."; return 1; fi
  if [ "$(commit_count)" -ge 1 ]; then
    local subj; subj="$(g log -1 --format=%s 2>/dev/null)"
    pass "commit made: \"$subj\". That snapshot is now saved in history — run 'git log' to see it."
  else
    fail "nothing committed yet. Run 'git commit', type a message in vim, then :wq (or use git commit -m \"...\")."
    return 1
  fi
}
