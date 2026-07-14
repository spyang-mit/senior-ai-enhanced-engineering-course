# shellcheck shell=bash disable=SC2034
TASK_TITLE="List an archive without extracting"
TASK_CAT="Moving bytes: tar"
TASK_BODY="Before you trust or unpack an archive, look inside it. The 't'
flag lists contents without writing anything to disk:
  tar tf  archive.tar       list a plain archive
  tar tzf archive.tar.gz    list a gzipped archive

Peek inside the archive you just made and save the file list:"
TASK_TRY="tar tzf notes.tar.gz > contents.txt"
TASK_WHY="Always list an archive before extracting a stranger's tarball — a
malicious one can contain absolute paths or '../' entries that write OUTSIDE
your target directory. 'tar t' is your safety check."
TASK_HINTS=(
  "Same flags as create, but 't' instead of 'c'. Redirect to a file."
  "Run: tar tzf notes.tar.gz > contents.txt"
)
check() {
  local f="$HOME/playground/contents.txt"
  if file_contains "$f" "notes/"; then
    pass "listed the archive's contents into contents.txt without unpacking."
  else
    fail "save the output of 'tar tzf notes.tar.gz' to contents.txt"; return 1
  fi
}
