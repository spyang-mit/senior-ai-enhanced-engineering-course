# shellcheck shell=bash disable=SC2034
TASK_TITLE="Read & change permissions"
TASK_CAT="Permissions"
TASK_BODY="Permissions decide WHO is allowed to do WHAT to a file. Unix sorts
everyone into three classes — the OWNER (user), the file's GROUP, and OTHERS
(everyone else) — and each class can separately be allowed to read, write, or
execute. So if only the owner's bits are set, the file is effectively private:
the owner can use it and nobody else can touch it.

Run 'ls -al' and read one line — it shows the permissions AND who owns the
file. Note the two name columns: the OWNER's name and the GROUP's name.

  -rwxr-x---  1  dev  staff  512  Jul 13 09:03  deploy.sh   (an example line)
  └────┬───┘     └┬┘  └─┬─┘
       │          │     └ GROUP that owns the file   (here: 'staff')
       │          └ USER that owns the file          (here: 'dev')
       └ type + permission bits — zoom in:

  d rwx r-x r-x
  │ └┬┘ └┬┘ └┬┘
  │  │   │   └ OTHERS (everyone else):  r-x = read + execute, no write
  │  │   └ GROUP:                       r-x = read + execute, no write
  │  └ OWNER (user):                    rwx = read + write + execute
  └ type:  d = directory,  - = regular file,  l = symlink

So r,w,x repeat three times — owner, group, others — and a '-' means OFF.

'chmod' turns those bits on and off, in the form chmod <who><+/-><perm>:
  who:  u = user/owner   g = group   o = others   a = all
  op:   +  add       -  remove
  perm: r  read      w  write     x  execute
Read them out loud:
  chmod g+w file   ->  ADD write permission for the GROUP
  chmod o-x file   ->  REMOVE execute permission from OTHERS

Your task: 'scripts/deploy.sh' is currently rw-r--r--. Change its permissions
so that:
  • the OWNER can read, write, and execute it
  • the GROUP can read and execute it, but NOT write
  • OTHERS have no access at all
That takes more than one change — chain a few chmod commands (or combine them
with commas). Watch it with 'ls -l scripts/deploy.sh' as you go."
TASK_TRY=""
TASK_WHY="Reading that permission string is a core debugging skill — 'permission
denied' bugs are invisible until you can look at the bits and see what's wrong.
AI-generated scripts constantly get these wrong (forgetting +x is the classic)."
TASK_HINTS=(
  "Owner needs execute added (+x); group needs execute added but keeps read; others need read removed. Three changes: u+x, g+x, o-r."
  "Run: chmod u+x scripts/deploy.sh ; chmod g+x scripts/deploy.sh ; chmod o-r scripts/deploy.sh   (or combined: chmod u+x,g+x,o-r scripts/deploy.sh)"
)
check() {
  local f="$HOME/playground/scripts/deploy.sh"
  file_exists "$f" || { fail "can't find $f"; return 1; }
  if mode_is "$f" 750; then
    pass "now $(symbolic_mode_of "$f"): owner rwx, group r-x, others nothing — you read the bits and set them."
  else
    fail "mode is $(symbolic_mode_of "$f"); goal is owner rwx, group r-x, others none (rwxr-x---)"; return 1
  fi
}
