# shellcheck shell=bash
# Reusable assertions used by task check() functions. Each returns 0/1 and
# leaves any human-readable explanation to the caller via pass()/fail().
# These run inside the `lesson` process, which is a child of the learner's
# shell — so it sees the same current directory, the same exported env vars,
# and of course the same real filesystem. (Shell aliases and unexported vars
# are NOT visible here, which is why alias/env tasks are checked via files
# or via exported variables instead.)

# --- filesystem -------------------------------------------------------------

file_exists() { [ -e "$1" ]; }

# Octal mode, e.g. "644". Uses GNU stat (present in the Debian sandbox).
mode_of() { stat -c '%a' "$1" 2>/dev/null; }

# Symbolic mode, e.g. "-rw-r--r--".
symbolic_mode_of() { stat -c '%A' "$1" 2>/dev/null; }

mode_is() { [ "$(mode_of "$1")" = "$2" ]; }

# Owner (first octal digit) has the execute bit.
owner_can_execute() {
  local m; m="$(mode_of "$1")" || return 1
  (( ( ${m: -3:1} & 1 ) != 0 ))
}

group_of() { stat -c '%G' "$1" 2>/dev/null; }
group_is() { [ "$(group_of "$1")" = "$2" ]; }

file_contains() { [ -e "$1" ] && grep -qE -- "$2" "$1"; }

# A file that exists and is not empty.
file_nonempty() { [ -s "$1" ]; }

# --- environment ------------------------------------------------------------

# Exact value of an exported env var (visible because `lesson` is a child proc).
env_is() { [ "${!1-}" = "$2" ]; }
env_set() { [ -n "${!1-}" ]; }

# A directory is present as an entry in $PATH.
path_contains() {
  case ":$PATH:" in *":$1:"*) return 0;; *) return 1;; esac
}

# --- command history --------------------------------------------------------

# Did the learner run a command matching <regex> recently? The sandbox shell is
# configured (PROMPT_COMMAND='history -a') to flush each command to
# ~/.bash_history immediately, so this sees commands from the current session.
history_has() {
  [ -r "$HOME/.bash_history" ] && grep -Eq -- "$1" "$HOME/.bash_history"
}

# --- location ---------------------------------------------------------------

cwd_is() { [ "$(pwd -P)" = "$(cd "$1" 2>/dev/null && pwd -P)" ]; }

# --- archives ---------------------------------------------------------------

# A readable gzip-compressed tar that contains a given path fragment.
gzip_tar_contains() {
  tar tzf "$1" 2>/dev/null | grep -qE -- "$2"
}
gzip_tar_valid() { tar tzf "$1" >/dev/null 2>&1; }

# --- remote (ssh/scp tasks) -------------------------------------------------

# Can we reach the backup host non-interactively with our key?
backup_host_reachable() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 backup@localhost true 2>/dev/null
}

# Does a path exist in the backup account's home?
backup_has() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 backup@localhost "test -e \"$1\"" 2>/dev/null
}

# Did at least one .tar.gz backup land in the backup account's ~/backups?
backup_has_tarball() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 backup@localhost \
    'ls ~/backups/*.tar.gz >/dev/null 2>&1' 2>/dev/null
}
