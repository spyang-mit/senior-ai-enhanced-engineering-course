# Module 1 — The command line & your environment

**Objective:** Be fluent and unafraid in a Unix shell — the layer AI helps a novice with
*least* safely. By the end you'll navigate a filesystem, read and set Unix permissions,
move bytes with `tar` and `scp` over `ssh`, and write an audited backup script — and you'll
have done all of it on a *real* Linux machine, not a simulation.

Most web servers are Linux. When you direct an AI agent to run shell commands, it will
sometimes emit something subtly destructive (`rm -rf`, an unquoted variable). If you can't
read the shell, you can't catch it. This module makes the shell a place you're comfortable.

---

## How this works: a throwaway Linux container

You'll do the hands-on work inside a **disposable Docker container** — a real Linux box that
you can wreck without any fear. Delete the wrong file, `rm -rf` the whole thing, whatever:
exit and re-enter and it's brand new. That safety is the entire reason we use a container
instead of practicing on your real laptop.

Inside the sandbox, a guide called **`lesson`** walks you task by task. You run *real*
commands; `lesson check` inspects the *real* result (the actual file mode, the actual
tarball, the actual backup that landed on the remote host) before letting you advance. There
is no multiple choice — only what actually happened.

### Step 1 — Install Docker (required)

The lesson needs Docker. If you run `./sandbox` without it, the script detects your OS and
prints exactly these instructions, then exits without touching anything.

- **macOS:** Install Docker Desktop from <https://www.docker.com/products/docker-desktop/>
  (or `brew install --cask docker`), then open the Docker app once so the engine starts.
- **Linux:** Install Docker Engine via your package manager (`sudo apt-get install docker.io`)
  or `curl -fsSL https://get.docker.com | sh`. Then `sudo usermod -aG docker "$USER"` (log out
  and back in) so you don't need `sudo`, and `sudo systemctl start docker`.
- **Windows:** Install Docker Desktop with the **WSL2 backend**, then run everything below
  from a **WSL2 shell** (Ubuntu) or Git Bash — *not* `cmd`/PowerShell. Bonus: inside WSL
  you're already using real Linux, which is exactly what this module wants.

### Step 2 — Enter the sandbox

From this module's directory:

```
./sandbox
```

The first run downloads a small Debian image and builds the sandbox (a minute or two). Later
runs are instant. You'll land at a shell inside the container with a welcome banner.

### Step 3 — Follow the guide

```
lesson next     # show what to do next
lesson check    # verify your work; on success, advance
lesson hint     # a nudge (ask again for a bigger one)
lesson map      # see all tasks and your progress
lesson skip     # move on without checking (unblock yourself)
lesson jump N   # go straight to task N (handy for review)
lesson reset    # start the whole lesson over
exit            # leave the container (it self-destructs)
```

Do a task, run `lesson check`, repeat. When you're done, type `exit` — the container
self-destructs. Nothing you did leaks onto your real machine.

The early tasks deliberately teach navigation the way a *human* actually works: you look
around with `ls`, then move **relative** to where you are (`cd projects`, `cd ..`) using
**tab-completion** — not by typing long absolute paths from the root the way an AI would.
Once you're back in `~/playground`, the rest of the commands are short and relative too
(`ls -al > listing.txt`, `chmod u+x scripts/deploy.sh`).

---

## Reference: reading `ls -al` column by column

Almost every permission bug is diagnosed by reading one line of `ls -al`. Here's the anatomy:

```
-rw-r--r--   1   dev   teammates   1240   Jul 13 09:03   report.txt
└────┬────┘  │   │     │           │      └─────┬─────┘   └────┬────┘
     │       │   │     │           │           │              └ name
     │       │   │     │           │           └ last-modified time
     │       │   │     │           └ size in bytes
     │       │   │     └ group that owns it
     │       │   └ user that owns it
     │       └ number of hard links
     └ file type + permission bits  (see below)
```

That first block breaks into four parts:

```
 -    rw-        r--        r--
 │    │          │          │
 │    │          │          └ OTHERS (everyone else): read only
 │    │          └ GROUP: read only
 │    └ USER (owner): read + write
 └ type:  -  file    d  directory    l  symlink
```

Each of the three permission triples is `r` (read), `w` (write), `x` (execute), in that
order; a `-` means that permission is off.

## Reference: permission bits and octal

Every permission has a number. Add them within each triple:

```
 r = 4     w = 2     x = 1
```

So a mode is three digits — owner, group, others:

| Octal | Symbolic    | Meaning                                             |
|-------|-------------|-----------------------------------------------------|
| `755` | `rwxr-xr-x` | owner: all; group & others: read + execute          |
| `644` | `rw-r--r--` | owner: read/write; everyone else: read              |
| `640` | `rw-r-----` | owner: read/write; group: read; others: nothing     |
| `600` | `rw-------` | owner only (how a private ssh key must be)          |
| `700` | `rwx------` | owner can do everything; nobody else can touch it   |

Two ways to set them, both taught in the lesson:

- **Symbolic** — relative changes: `chmod u+x file` (add owner execute),
  `chmod g+w file` (add group write), `chmod o-r file` (remove others' read),
  `chmod o+r file` (add others' read).
- **Octal** — absolute: `chmod 755 file`, `chmod 640 file`.

Ownership is the other half: a file has an owning **user** and **group**. `chown user file`
changes the user (usually needs root); `chgrp group file` changes the group;
`chown user:group file` sets both. Permission bits only mean something once you know *who*
owns the file — that's why the lesson pairs `chmod` with `chgrp`.

---

## The two strands (they run through every module)

**🎯 Direct the AI.** Read *every line* of shell an agent generates before you run it. This is
where AI most often emits something subtly destructive: `rm -rf` with a variable that might be
empty, an unquoted `$VAR` that splits on spaces, a `>` that clobbers the wrong file, a command
that assumes a permission or a PATH entry that isn't there. You now know enough to catch these.

**✅ Verify it.** Never run a destructive generated command blind. Run it in a throwaway
directory (or this container). Check exit codes (`echo $?`). List a tarball (`tar tzf`) before
extracting it. Inspect the actual file mode after a `chmod`, not just that the command "ran."

---

## Project — an audited backup script

Your deliverable is the script you build in the final lesson task: **`backup.sh`**, which

1. archives a directory with `tar` (compressed, `.tar.gz`),
2. ships it to another machine with `scp` over `ssh`, and
3. **reports success or failure via exit codes** — it checks that each step actually worked
   instead of blindly printing "done."

The lesson's last `check` confirms your script ran and a real archive landed on the backup
host. Build it yourself first. A fully-audited reference is in
[`sample-solution/backup.sh`](sample-solution/backup.sh), and the prompt I used to have an
agent draft it (and what I made it fix) is in
[`sample-solution/original_prompt.txt`](sample-solution/original_prompt.txt) — read those
only *after* your own attempt.

**What "audited" means here** — the senior habits the sample demonstrates:
- `set -euo pipefail` so the script stops at the first failure instead of charging ahead.
- Every variable quoted (`"$VAR"`) so a path with a space — or an empty value — can't turn a
  command destructive.
- Explicit exit-code checks with a clear message on failure.
- No hard-coded secrets; the source and destination are arguments/variables, not surprises.

---

## Quiz

Test yourself with [`quizzes/module-1-quiz.md`](quizzes/module-1-quiz.md) — reading an
`ls -al` line, converting between symbolic and octal, and spotting the dangerous line in a
generated script. Answers are at the bottom.

## What's next

Module 2 puts this script under **git and GitHub** and adds the survival **vi** skills you'll
need to write commit messages — the pager navigation you used in `man` (`/` to search, `q` to
quit) is a first taste of it.
