# Module 1 Quiz — the command line & your environment

Try to answer before looking at the key at the bottom. If a question is about a
command's behavior, the best move is to *try it in the sandbox* and see.

---

**1. Reading `ls -al`.** Given this line:

```
-rwxr-x---  1  dev  teammates  2048  Jul 13 09:03  deploy.sh
```

a) Is it a file or a directory?
b) Who can execute it?
c) Can a user who is *not* `dev` and *not* in `teammates` read it?
d) What is this mode in octal?

**2. Octal → symbolic.** Write the symbolic form (like `rw-r--r--`) of:
a) `755`  b) `640`  c) `600`

**3. Symbolic → octal.** You start with `rw-r--r--` (644) and run
`chmod g+w,o-r file`. What is the new mode, in both symbolic and octal?

**4. Which chmod?** You have a private ssh key and ssh refuses to use it because
it's "too open." What one command locks it to owner-only read/write?

**5. `>` vs `>>`.** What is the difference between
`echo hi > notes.txt` and `echo hi >> notes.txt`? Which one can silently
destroy data, and why?

**6. Pipes.** In plain English, what does this do?

```
grep ERROR server.log | wc -l
```

**7. PATH.** You install a tool but typing its name gives `command not found`,
even though the file exists and is executable. What is almost certainly wrong,
and what would you inspect to confirm it?

**8. export.** What's the difference between `NAME=value` and
`export NAME=value`? Which one will a script you launch be able to see?

**9. tar flags.** Match each to create / list / extract:
a) `tar czf archive.tar.gz dir`
b) `tar tzf archive.tar.gz`
c) `tar xzf archive.tar.gz`
And: what does the `z` add in all three?

**10. Aliases & dotfiles.** You run `alias ll='ls -al'` and it works, but after
you close the terminal and open a new one, `ll` is gone. Why — and where do you
put it so it survives?

**11. Exit codes.** After running a command, `echo $?` prints `0`. What does
that mean? What would a nonzero value mean, and how do `&&` and `||` use it?

**12. Read the AI's shell (the important one).** An agent generated this cleanup
step in a script:

```bash
rm -rf $BUILD_DIR/
```

Name two distinct reasons this line is dangerous, and rewrite it more safely.

---

## Answer key

**1.** a) A file (leading `-`; a `d` would mean directory).
b) The owner (`dev`) — the owner triple is `rwx`. The group `teammates` has
`r-x` so group members can execute too; "others" have `---`.
c) No — the "others" bits are `---`, so anyone outside the owner and group gets
nothing. d) `750`.

**2.** a) `rwxr-xr-x`  b) `rw-r-----`  c) `rw-------`.

**3.** `g+w` turns `rw-r--r--` into `rw-rw-r--` (664); then `o-r` removes others'
read → `rw-rw----`, which is **660**.

**4.** `chmod 600 <keyfile>` (equivalently `chmod u=rw,go= <keyfile>`).

**5.** `>` **replaces** the entire contents of the file (creating it if needed);
`>>` **appends** to the end. `>` is the destructive one: aim it at an existing
file by mistake and its previous contents are gone, with no undo.

**6.** Finds every line in `server.log` containing "ERROR" and counts them —
`grep` selects the matching lines, the pipe feeds them to `wc -l`, which counts
lines. Net result: how many error lines are in the log.

**7.** The tool's directory isn't on your `PATH`. Inspect it with
`echo $PATH` or `env | grep PATH`; fix by adding the directory, e.g.
`export PATH="/path/to/dir:$PATH"`.

**8.** `NAME=value` sets a variable that lives only in the current shell.
`export NAME=value` marks it for the *environment*, so child processes (the
scripts and programs you run) inherit it. Only the exported one is visible to a
script you launch.

**9.** a) create, b) list (show contents without extracting), c) extract. The
`z` means gzip — compress on create, decompress on list/extract (`.tar.gz`).

**10.** An alias set at the prompt lives only in that shell session; it isn't
saved anywhere. Put the line `alias ll='ls -al'` in a startup dotfile —
`~/.bashrc` — which runs for every new shell. Run `source ~/.bashrc` to load it
into the current session immediately.

**11.** `0` means the command **succeeded**. Any nonzero value means it failed
(different numbers can indicate different failures). `cmd1 && cmd2` runs `cmd2`
only if `cmd1` exited 0; `cmd1 || cmd2` runs `cmd2` only if `cmd1` failed.

**12.** Two of several reasons: (a) `$BUILD_DIR` is **unquoted**, so a value
with spaces splits into multiple arguments — and if it's **empty/unset**, the
line becomes `rm -rf /` (delete everything). (b) The trailing `/` combined with
an empty variable targets the filesystem root. (c) `-rf` gives no confirmation
and ignores errors. Safer:

```bash
set -u                       # unset variable is now an error, not ""
: "${BUILD_DIR:?BUILD_DIR must be set}"
rm -rf -- "$BUILD_DIR"       # quoted, and -- stops option parsing
```
