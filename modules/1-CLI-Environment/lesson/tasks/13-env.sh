# shellcheck shell=bash disable=SC2034
TASK_TITLE="Inspect the environment"
TASK_CAT="Environment variables"
TASK_BODY="Your shell carries a set of environment variables — settings that
programs read. See them with:
  env               print all of them
  echo \$HOME        print one
  env | grep PATH   filter to just the PATH-related ones

PATH is special: it's the colon-separated list of directories the shell
searches to find a command. Filter env down to PATH and save it:"
TASK_TRY="env | grep PATH > ~/playground/path.txt"
TASK_WHY="When 'command not found' happens even though the tool is installed,
it's almost always PATH. Knowing how to inspect the environment is how you
debug it."
TASK_HINTS=(
  "Pipe env into grep to filter, then redirect to the file."
  "Run: env | grep PATH > ~/playground/path.txt"
)
check() {
  local f="$HOME/playground/path.txt"
  if file_contains "$f" "PATH"; then
    pass "captured your PATH environment — that's the search list for commands."
  else
    fail "no PATH line saved to ~/playground/path.txt yet"; return 1
  fi
}
