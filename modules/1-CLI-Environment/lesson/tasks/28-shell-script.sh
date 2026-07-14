# shellcheck shell=bash disable=SC2034
TASK_TITLE="Write & run a shell script"
TASK_CAT="Shell scripting"
TASK_BODY="Everything you've been typing can live in a SCRIPT — a file of
commands you run over and over. Let's write one and make it runnable.

1. Open a new file in 'nano', a simple terminal text editor:
     nano hello.sh
2. Type exactly these two lines:
     #!/usr/bin/env bash
     echo 'Hello World'
3. Save and quit nano:  press Ctrl-O then Enter (to write it out), then
   Ctrl-X (to exit).
4. Make the file executable (the same kind of chmod from the permissions tasks).
5. Run it from the current directory:
     ./hello.sh

Two things to understand:
  • That first line '#!/usr/bin/env bash' is called the 'shebang' — it tells
    the system which interpreter should run the file (here, bash).
  • You run it as './hello.sh', not just 'hello.sh'. The shell only auto-finds
    commands on your PATH; to run a script sitting in the current folder, you
    point at it with './' (which means 'right here')."
TASK_TRY=""
TASK_WHY="A script is just commands in a file. Three things turn it into a
program you can run: the shebang (which interpreter), the execute bit (chmod
+x), and running it by path (./name). That's the foundation of every build
script, deploy script, and automation you'll ever write."
TASK_HINTS=(
  "After you save in nano: make it executable with chmod +x hello.sh, then run ./hello.sh"
  "'permission denied' means you skipped the chmod +x. 'command not found' means you forgot the ./ in front."
)
check() {
  local f="$HOME/playground/hello.sh"
  if [ ! -f "$f" ]; then
    fail "create the script first: nano hello.sh"; return 1
  fi
  if ! owner_can_execute "$f"; then
    fail "hello.sh exists but isn't executable yet — chmod +x hello.sh"; return 1
  fi
  if "$f" 2>/dev/null | grep -q "Hello World"; then
    pass "hello.sh runs and prints 'Hello World' — you wrote, permissioned, and ran a real script."
  else
    fail "running ./hello.sh should print 'Hello World' — check the two lines inside it"; return 1
  fi
}
