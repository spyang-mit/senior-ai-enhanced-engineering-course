# shellcheck shell=bash disable=SC2034
TASK_TITLE="Make directories (mkdir)"
TASK_CAT="Files"
TASK_BODY="'mkdir' makes a new directory:
  mkdir name        create one directory here
  mkdir -p a/b/c    create a whole nested path at once, making parents as needed

Two path shortcuts you've met while navigating also work when NAMING where to
create things:
  .    means 'the current directory'
  ..   means 'the parent directory'
So from inside a folder, 'mkdir ../blah' makes a directory in the PARENT, right
next to the one you're standing in. Paths are relative to where you are.

Your task:
  1. In your playground, make a folder called 'workspace' with a subfolder
     'drafts' inside it — in ONE command.
  2. Then practice a relative reference: cd into workspace, and from there
     create a folder named 'inbox' in the PARENT (i.e. back in the playground)
     using '..'.
  3. Return to the playground root when you're done."
TASK_TRY=""
TASK_WHY="Building directory trees and referring to places relative to where you
are ('..', '.') is everyday work. Once you can say 'the parent' or 'two levels
up' in a path, you stop needing long absolute paths for everything."
TASK_HINTS=(
  "One command for the nested pair: mkdir -p workspace/drafts. Then: cd workspace, and make the sibling with mkdir ../inbox."
  "Run: mkdir -p workspace/drafts   then   cd workspace && mkdir ../inbox && cd ~/playground"
)
check() {
  local pg="$HOME/playground"
  if [ -d "$pg/workspace/drafts" ] && [ -d "$pg/inbox" ]; then
    pass "workspace/drafts and inbox both exist — and you made 'inbox' with a relative '..' path."
  elif [ -d "$pg/workspace/drafts" ]; then
    fail "workspace/drafts is there; now cd into workspace and make its sibling 'inbox' with: mkdir ../inbox"
    return 1
  else
    fail "make workspace with a drafts subfolder first: mkdir -p workspace/drafts"
    return 1
  fi
}
