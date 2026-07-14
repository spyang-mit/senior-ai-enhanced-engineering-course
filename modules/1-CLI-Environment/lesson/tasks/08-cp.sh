# shellcheck shell=bash disable=SC2034
TASK_TITLE="Copy files & folders (cp)"
TASK_CAT="Files"
TASK_BODY="'cp' copies. The last argument is the destination:
  cp file newname       copy a file to a new name (in the same folder)
  cp file dir/          copy a file INTO an existing directory (keeps its name)
  cp -r dir dest        copy a whole directory and its contents (needs -r)

The destination can be a relative path too, so 'cp report.txt ../' copies it up
into the parent directory.

Your task:
  1. Make a backup of notes/todo.txt right next to it, named notes/todo.bak.
  2. Copy your entire notes/ directory to a new folder called notes-backup."
TASK_TRY=""
TASK_WHY="Copying before you change something is the poor-man's undo — 'cp
config config.bak' takes a second and saves you when an edit goes wrong. Note
that copying a DIRECTORY needs -r; without it, cp refuses."
TASK_HINTS=(
  "A file copy is 'cp src dest'; a directory copy needs -r. Two commands here."
  "Run: cp notes/todo.txt notes/todo.bak   then   cp -r notes notes-backup"
)
check() {
  local pg="$HOME/playground"
  if [ ! -f "$pg/notes/todo.bak" ]; then
    fail "make the file backup first: cp notes/todo.txt notes/todo.bak"; return 1
  fi
  if [ -f "$pg/notes-backup/todo.txt" ]; then
    pass "todo.bak made, and the whole notes/ folder copied to notes-backup/ (that's what -r is for)."
  else
    fail "now copy the whole directory: cp -r notes notes-backup"; return 1
  fi
}
