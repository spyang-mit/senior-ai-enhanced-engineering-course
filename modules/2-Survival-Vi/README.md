# Module 2 — Survival vi

**Objective:** Learn just enough vi to *survive* it — open a file, make an edit, save, and (most
important of all) **get out without saving** when you've made a mess. You don't need mastery.

Why bother? **vi (and vim) is preinstalled on nearly every Linux server in the world.** It's
awkward, but very often it's the *only* editor on a box you've just logged into — which is why
every seasoned Linux developer knows the basics. And it comes before git for a concrete reason:
**git drops you into vi to write commit messages by default.** Ten minutes of drilling here means
that blank vi screen never stops you again.

---

## How this works: a throwaway container + a guide

Same setup as Module 1: you work inside a **disposable Docker container** with real `vim`, and
a guide called **`lesson`** walks you through it. Each task hands you a file and a target; you
edit it in vim, and `lesson check` compares the file you saved against the goal. Mangle
anything you like — exit and re-enter for a clean slate.

### Step 1 — Install Docker (required)

If you did Module 1 you already have it. If not, `./sandbox` prints tailored instructions when
Docker is missing. In short:

- **macOS:** Docker Desktop from <https://www.docker.com/products/docker-desktop/> (or
  `brew install --cask docker`), then open the app once so the engine starts.
- **Linux:** `sudo apt-get install docker.io` (or `curl -fsSL https://get.docker.com | sh`),
  then `sudo systemctl start docker`.
- **Windows:** Docker Desktop with the **WSL2 backend**, and run `./sandbox` from a WSL2 shell.

### Step 2 — Enter the sandbox

From this module's directory:

```
./sandbox
```

### Step 3 — Follow the guide

```
lesson next     # show the next task (it seeds the file you'll edit)
lesson check    # compare your saved file against the target
lesson hint     # a nudge (ask again for the exact keystrokes)
lesson map      # see all tasks
lesson jump N   # jump to task N
lesson reset    # start over
exit            # leave the container (it self-destructs)
```

Do a task, `lesson check`, repeat. **Messed a file up beyond fixing?** Every task can re-seed:
`rm <the-file>` then `lesson next` gives you a fresh copy.

---

## The one thing to remember

If you take nothing else from this module: when vi has you trapped,

```
press Esc   then type   :q!   and press Enter
```

That quits and **throws away** your changes. You are never stuck.

## Reference: modes

vi has **modes**, and that's the whole reason it feels weird:

- **Normal mode** (where you start): letters are *commands*, not text. `dd` deletes a line,
  `x` deletes a character. Press **Esc** any time to return here.
- **Insert mode**: what you type becomes text. Enter it with `i` (and friends, below); you'll
  see `-- INSERT --` at the bottom. Leave it with **Esc**.
- **Command-line** (the `:` line at the bottom): `:w`, `:q`, `:wq`, `:q!`, `:5` — type and
  press Enter.

## Reference: survival cheat-sheet

| Goal | Keys |
|---|---|
| Quit, discard changes | `:q!` |
| Quit (no changes made) | `:q` |
| Save | `:w` |
| Save **and** quit | `:wq` (or `ZZ`) |
| Insert before / after cursor | `i` / `a` |
| Insert at end of line | `A` |
| Open new line below / above | `o` / `O` |
| Move (left/down/up/right) | `h` `j` `k` `l` |
| Word forward / back | `w` / `b` |
| Start / end of line | `0` / `$` |
| Top / bottom of file | `gg` / `G` |
| Go to line N | `:N` |
| Delete char / word / line | `x` / `dw` / `dd` |
| Delete to end of line | `D` |
| Replace one char | `r<char>` |
| Change word / to end of line | `cw` / `C` |
| Undo / redo | `u` / `Ctrl-R` |
| Yank (copy) line / paste below / above | `yy` / `p` / `P` |
| Move a line | `dd` then `p` (cut, then paste) |
| Select a block: characters / whole lines | `v` / `V` |
| Copy / cut / paste a selection | `y` / `d` / `p` |
| Search forward, next / prev match | `/text` then `n` / `N` |

Many commands take a **count**: `3dd` deletes three lines, `5j` moves down five.

---

## Quiz

Test yourself with the interactive quiz — it grades itself and explains each answer. It's a
standalone HTML page; open it in your browser. On a Mac, from this directory:

```
open quizzes/module-2-quiz.html
```

(On Linux: `xdg-open quizzes/module-2-quiz.html`; or just double-click it.)

## What's next

**Module 3 — Git: local version control.** Your first `git commit` there will open vi for the
commit message. You'll type `:wq`, close it without a second thought, and realize this module
already paid for itself.
