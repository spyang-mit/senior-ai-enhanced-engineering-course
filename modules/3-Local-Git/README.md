# Module 3 — Git: local version control

**Objective:** Become genuinely fluent with git — *locally*. Stage and commit, branch and
merge, cherry-pick and rebase, and (the part that scares most people) resolve a merge conflict
and come out with a clean history.

**Why local-only?** We deliberately skip the GitHub *collaboration* layer — accounts, pull
requests, CI — which adds friction for little conceptual payoff at this stage. Everything that
actually *matters* about git happens on your own machine: the commit graph, branches, merging,
and conflict resolution. Master that and the online layer (which returns later, with deployment)
is easy. As a bonus, the last three tasks demo the *mechanics* of `push`, `pull`, and `clone`
against a second local repository standing in for a remote — contrived, but the exact commands
you'd run against GitHub.

---

## How this works: a throwaway container + a guide

Same setup as Modules 1–2: a **disposable Docker container** with git preconfigured, and a guide
called **`lesson`**. Each task's setup builds the exact repo state it needs (branches, commits,
even a conflict), so tasks are independent — you can `lesson jump` anywhere. The check inspects
the real repo (the log, branches, file contents, merge/rebase state).

Git's editor here is **vim** — so your very first `git commit` opens vim for the message, and
Module 2 pays off immediately.

### Step 1 — Install Docker (required)

If you did Modules 1–2 you already have it. Otherwise `./sandbox` prints tailored instructions;
in short: macOS → Docker Desktop (or `brew install --cask docker`); Linux →
`sudo apt-get install docker.io` then `sudo systemctl start docker`; Windows → Docker Desktop
(WSL2 backend), run `./sandbox` from a WSL2 shell.

### Step 2 — Enter the sandbox

```
./sandbox
```

### Step 3 — Follow the guide

```
lesson next     # show the next task (its setup builds the repo you'll work in)
lesson check    # verify the repo state against the goal
lesson hint     # a nudge (ask again for the exact commands)
lesson map      # see all tasks
lesson jump N   # jump to task N (rebuilds that task's repo)
lesson reset    # start over
exit            # leave the container (it self-destructs)
```

**Stuck mid-operation** (a half-finished rebase or merge)? Every task re-seeds: run `lesson next`
(or `lesson jump N`) to get a fresh repo for that task and try again.

---

## The mental model: three places a change lives

```
   working tree   --git add-->   staging area   --git commit-->   repository (history)
   (your files)                  (index)                          (permanent snapshots)
```

- **`git status`** is your compass — run it constantly. It tells you the branch, what's changed,
  and what's staged.
- A **commit** is a snapshot of the staging area plus a message explaining *why*. Each has a
  unique hash.
- A **branch** is just a cheap, movable pointer to a commit — a separate line of work.

## Merge vs. rebase (the one that confuses everyone)

Both combine work from two branches; they differ in the history they leave:

- **`git merge`** ties the two lines together, keeping the fork visible (and creating a *merge
  commit* when both sides moved).
- **`git rebase`** replays your branch's commits *on top of* the target, producing a straight,
  linear history — as if you'd started from the latest main. Rebase your own local work; don't
  rebase history others already have.

## Resolving a conflict (survival steps)

A conflict just means two changes touched the same lines and git won't guess. It marks the file:

```
<<<<<<< HEAD
your current side
=======
the incoming side
>>>>>>> other-branch
```

To resolve: **edit the file to what you actually want, delete all three marker lines**, then
`git add` it — and *finish the operation the right way, which depends on which one you're in*:

```
git add <file>            # mark this file resolved, then:
# during a REBASE:  git rebase --continue      <-- NOT git commit
# during a MERGE:   git commit
```

> ⚠ **The rebase trap.** After resolving a *rebase* conflict, finish with `git rebase --continue`,
> never `git commit`. Mid-rebase you're on a **detached HEAD**: `git commit` makes a commit your
> branch doesn't point to and leaves the rebase unfinished — switch away and the work is orphaned.
> (Recovery if you slip: `git rebase --continue` still finishes it, or `git rebase --abort` restarts.)

Not ready to deal with it? **`git merge --abort`** (or `git rebase --abort`) backs out completely.

## Command cheat-sheet

| Goal | Command |
|---|---|
| Start a repo | `git init` |
| See state | `git status` |
| Stage a change | `git add <file>` |
| Commit staged (opens vim) | `git commit` |
| Commit tracked changes in one step | `git commit -a -m "msg"` |
| See unstaged changes | `git diff` |
| History (compact) | `git log --oneline` |
| New branch + switch | `git checkout -b <name>` |
| Switch branch | `git checkout <name>` |
| Merge a branch into the current one | `git merge <name>` |
| Copy one commit here | `git cherry-pick <hash>` |
| Replay branch onto another | `git rebase <name>` |
| Squash/clean up recent commits | `git rebase -i HEAD~N` (set `pick` → `s`) |
| Finish after resolving | `git add <file>` → `git rebase --continue` |
| Bail out of a merge / rebase | `git merge --abort` / `git rebase --abort` |
| See configured remotes | `git remote -v` |
| Send commits to the remote | `git push` |
| Force-push rewritten history (careful!) | `git push --force` (safer: `--force-with-lease`) |
| Fetch + merge the remote's commits | `git pull` |
| Copy an existing repo into a new folder | `git clone <url> <folder>` |

---

## Quiz

Test yourself with the interactive quiz — it grades itself and explains each answer. Open it in
your browser; on a Mac, from this directory:

```
open quizzes/module-3-quiz.html
```

(Linux: `xdg-open quizzes/module-3-quiz.html`; or double-click it.)

Once that feels easy, try the **advanced quiz** — harder, and it reaches past this module into
real-world git (reflog, reset modes, revert, stash, bisect, tags, detached HEAD, `--force-with-lease`).
Anything you miss is a recovery tool worth having:

```
open quizzes/module-3-quiz-advanced.html
```

## What's next

You can now version-control anything locally and never lose work. The rest of the course builds
on this — every module from here lives in a git repo, on branches, with commits that explain why.
