# shellcheck shell=bash disable=SC2034
TASK_TITLE="Extract an archive"
TASK_CAT="Moving bytes: tar"
TASK_BODY="'x' extracts an archive. The flags:
  x = extract   z = gunzip   f = file

Key thing to know: by DEFAULT, tar extracts into your CURRENT directory. So the
normal, human way to control WHERE files land is to first cd to the folder you
want them in, then extract. An archive can hold many files, so you usually make
a fresh folder for them and unpack from inside it.

Someone left you a compressed archive of old logs at archive/oldlogs.tar.gz.

Your task: unpack it so the files land in a NEW folder called 'restored'. Do it
the human way — make the folder, cd into it, and extract from there. (The
archive will then be one level up, so you'll reach it with '..'.)

Aside: scripts often use 'tar xzf file -C targetdir' to extract INTO targetdir
without cd-ing — handy, but the default is 'right here where I'm standing'."
TASK_TRY=""
TASK_WHY="Extracting blindly into your working directory is how people end up
with 40 stray files everywhere. Making a folder and extracting from inside it
keeps things tidy — and reusing '..' to reach the archive is exactly the
relative-path habit you've been building."
TASK_HINTS=(
  "mkdir restored, cd into it, then extract the archive from up one level: tar xzf ../archive/oldlogs.tar.gz"
  "Run: mkdir restored && cd restored && tar xzf ../archive/oldlogs.tar.gz && cd ~/playground"
)
check() {
  local d="$HOME/playground/restored"
  if [ -d "$d" ] && [ -n "$(find "$d" -type f 2>/dev/null | head -1)" ]; then
    pass "extracted the old logs into restored/ — files are there."
  else
    fail "expected extracted files under restored/"; return 1
  fi
}
