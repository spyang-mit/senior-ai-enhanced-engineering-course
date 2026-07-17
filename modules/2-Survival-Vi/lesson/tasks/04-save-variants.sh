# shellcheck shell=bash disable=SC2034
TASK_TITLE="Save and quit, every which way"
TASK_CAT="Editing"
TASK_BODY="The write/quit commands, all from normal mode (press Esc first):
  :w    write (save) but STAY in vi
  :wq   write and quit   (ZZ does the same thing)
  :q    quit — only works if there are no unsaved changes
  :q!   quit and discard changes (the panic button from task 1)

Starting from a file with one line, you'll add two lines and use :w between
them. Open journal.txt and make it read:
  Monday: started the vi module
  Tuesday: learned to save with :w
  Wednesday: and to save-and-quit with :wq
Add the Tuesday line, run :w to save, add the Wednesday line, then :wq.
  vim journal.txt"
TASK_TRY="vim journal.txt"
TASK_WHY="':w' (save without leaving) is what you'll lean on while working — save
often, keep editing. ':wq' is how you finish. Knowing both means you never
lose work and never feel trapped."
TASK_HINTS=(
  "Go to the end (G), open a line with o, type the Tuesday line, Esc, then :w. Then o again, type the Wednesday line, Esc, then :wq."
  "The exact lines: 'Tuesday: learned to save with :w' and 'Wednesday: and to save-and-quit with :wq'."
)
setup() {
  local f="$HOME/playground/journal.txt"
  [ -e "$f" ] || printf 'Monday: started the vi module\n' > "$f"
}
check() {
  local f="$HOME/playground/journal.txt"
  [ -f "$f" ] || { fail "journal.txt is missing — run 'lesson next' for a fresh copy"; return 1; }
  if file_is "$f" <<'EOF'
Monday: started the vi module
Tuesday: learned to save with :w
Wednesday: and to save-and-quit with :wq
EOF
  then
    pass "three lines saved — you used :w to save mid-edit and :wq to finish."
  else
    fail "aim for the three Monday/Tuesday/Wednesday lines shown in the task"
    show_diff "$f" <<'EOF'
Monday: started the vi module
Tuesday: learned to save with :w
Wednesday: and to save-and-quit with :wq
EOF
    return 1
  fi
}
