# shellcheck shell=bash
# Assertions and repo-builders for the local-git lesson. Checks run inside the
# `lesson` process (a child of your shell) and inspect the real repo at
# ~/playground. Each task's setup() rebuilds that repo to its precondition, so
# tasks are independent and you can jump around freely.

REPO="$HOME/playground"
g() { git -C "$REPO" "$@"; }        # run git against the lesson repo

# --- repo state -------------------------------------------------------------

is_repo()       { g rev-parse --git-dir >/dev/null 2>&1; }
commit_count()  { g rev-list --count HEAD 2>/dev/null || echo 0; }
working_clean() { is_repo && [ -z "$(g status --porcelain 2>/dev/null)" ]; }
is_staged()     { g diff --cached --name-only 2>/dev/null | grep -qxF -- "$1"; }
is_tracked()    { g ls-files --error-unmatch -- "$1" >/dev/null 2>&1; }
branch_exists() { g show-ref --verify --quiet "refs/heads/$1"; }
current_branch(){ g rev-parse --abbrev-ref HEAD 2>/dev/null; }
on_branch()     { [ "$(current_branch)" = "$1" ]; }
log_has()       { g log --all --format=%s 2>/dev/null | grep -qF -- "$1"; }

merge_in_progress()  { [ -f "$REPO/.git/MERGE_HEAD" ]; }
rebase_in_progress() { [ -d "$REPO/.git/rebase-merge" ] || [ -d "$REPO/.git/rebase-apply" ]; }
# unmerged (conflicted) paths currently present?
has_conflicts()      { [ -n "$(g diff --name-only --diff-filter=U 2>/dev/null)" ]; }

# --- file content -----------------------------------------------------------

file_exists()   { [ -e "$1" ]; }
file_contains() { [ -e "$1" ] && grep -qE -- "$2" "$1"; }
has_conflict_markers() { [ -e "$1" ] && grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$1"; }

# Normalize (strip trailing whitespace + trailing blank lines) then compare a
# file to expected content read from stdin.
_norm() {
  sed 's/[[:space:]]*$//' "$1" | awk '
    { lines[NR] = $0 }
    END { n = NR; while (n > 0 && lines[n] == "") n--; for (i = 1; i <= n; i++) print lines[i] }'
}
file_is() {
  local f="$1"; [ -f "$f" ] || return 1
  local tmp; tmp="$(mktemp)"; cat > "$tmp"
  local rc=0; diff <(_norm "$f") <(_norm "$tmp") >/dev/null 2>&1 || rc=1
  rm -f "$tmp"; return $rc
}
show_diff() {
  local f="$1"; local tmp; tmp="$(mktemp)"; cat > "$tmp"
  printf '%s\n' "${C_DIM}--- expected vs your file ---${C_RESET}"
  diff --label expected --label yours -u <(_norm "$tmp") <(_norm "$f") 2>/dev/null | sed -n '3,14p' | sed 's/^/  /'
  rm -f "$tmp"
}

# --- repo builders (used by task setup functions) ---------------------------

# Empty ~/playground back to a bare directory (no repo yet) WITHOUT removing the
# directory itself — the learner's shell is sitting in it, so deleting it would
# invalidate their working directory. This clears contents including dotfiles
# (like an existing .git) but keeps the directory's inode.
repo_reset() {
  mkdir -p "$REPO"
  find "$REPO" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

# Write a file (content on stdin) relative to the repo.
repo_write() { local f="$1"; cat > "$REPO/$f"; }

# Commit a single file with given content and message: repo_commit <file> <msg> <<<content
repo_commit() {
  local f="$1" msg="$2"; cat > "$REPO/$f"
  g add -- "$f"; g commit -q -m "$msg"
}

# A fresh repo with one initial commit (main branch). Leaves you on main.
repo_init_with_commit() {
  repo_reset
  g init -q -b main
  printf 'line one\nline two\nline three\n' > "$REPO/README.md"
  g add -A; g commit -q -m "Initial commit"
}
