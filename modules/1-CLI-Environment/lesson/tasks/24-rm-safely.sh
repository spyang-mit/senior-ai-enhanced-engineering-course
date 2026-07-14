# shellcheck shell=bash disable=SC2034
TASK_TITLE="Delete files (carefully)"
TASK_CAT="Deleting safely"
TASK_BODY="'rm' removes files. There is no recycle bin — rm is forever.
  rm file       delete a file
  rm -i file    ask before each delete (good habit)
  rm -r dir     delete a directory and everything in it (recursive)
  rm -rf dir    recursive + force, no prompts — the dangerous one

Your task: you created hello.txt earlier — delete it."
TASK_TRY=""
TASK_WHY="This is THE command to read twice in AI-generated scripts. 'rm -rf
\$DIR/' with an empty or wrong \$DIR has wiped real systems. Danger signs:
unquoted variables, a leading '/', or '-rf' near a variable path. In this
throwaway container you can experiment fearlessly — that's the whole point."
TASK_HINTS=(
  "Just remove the one file. (Try 'rm -i' to see the confirm prompt.)"
  "Run: rm hello.txt"
)
check() {
  if ! file_exists "$HOME/playground/hello.txt"; then
    pass "hello.txt is gone — and there's no undo. Respect rm."
  else
    fail "hello.txt is still there; remove it with rm"; return 1
  fi
}
