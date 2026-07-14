# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create a permanent alias"
TASK_CAT="Aliases & dotfiles"
TASK_BODY="An alias is a shortcut for a longer command:
  alias ll='ls -al'    now 'll' means 'ls -al'

But an alias set this way vanishes when you close the shell. To make it
permanent, add it to a 'dotfile' that runs every time a shell starts —
~/.bashrc. Append the alias to it:
  echo \"alias ll='ls -al'\" >> ~/.bashrc
Then load it into your current shell without reopening:
  source ~/.bashrc"
TASK_TRY="echo \"alias ll='ls -al'\" >> ~/.bashrc"
TASK_WHY="Dotfiles (.bashrc, .profile, .gitconfig, .ssh/config) are where you
encode your setup so it follows you to every machine. Engineers keep them in
a git repo. (Aliases live only in your shell, so this check reads .bashrc —
that's also exactly where the alias needs to be to persist.)"
TASK_HINTS=(
  "Append the alias line to ~/.bashrc with >>, then source it."
  "echo \"alias ll='ls -al'\" >> ~/.bashrc   then   source ~/.bashrc"
)
check() {
  if file_contains "$HOME/.bashrc" "alias ll=.?ls -al"; then
    pass "ll is now a permanent alias in ~/.bashrc. Run 'source ~/.bashrc' then try 'll'."
  else
    fail "add  alias ll='ls -al'  to ~/.bashrc"; return 1
  fi
}
