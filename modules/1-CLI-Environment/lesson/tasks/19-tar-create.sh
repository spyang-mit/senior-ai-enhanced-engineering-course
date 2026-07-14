# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create a tar archive"
TASK_CAT="Moving bytes: tar"
TASK_BODY="'tar' bundles many files into one archive — the standard way to
package a directory for backup or transfer. Decode the flags:
  c = create    x = extract   t = list (show contents)
  v = verbose (print names)   f = the archive FILE comes next
  z = gzip-compress (.tar.gz)

Create a COMPRESSED archive of your notes directory (you're in ~/playground,
so just name it):
  tar czf notes.tar.gz notes"
TASK_TRY="tar czf notes.tar.gz notes"
TASK_WHY="Read 'czf' as 'create, gzip, file'. Add 'v' (tar cvzf) any time you
want to watch what's being added. This is exactly what your backup-script
project will do to a directory before shipping it."
TASK_HINTS=(
  "From ~/playground: tar c(create) z(gzip) f(file) <archive> <dir>."
  "Run: tar czf notes.tar.gz notes"
)
check() {
  local f="$HOME/playground/notes.tar.gz"
  if gzip_tar_valid "$f" && gzip_tar_contains "$f" "notes/"; then
    pass "notes.tar.gz created and it contains your notes/ directory."
  else
    fail "expected a valid gzip archive at notes.tar.gz containing notes/"; return 1
  fi
}
