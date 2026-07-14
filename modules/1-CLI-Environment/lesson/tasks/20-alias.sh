# shellcheck shell=bash disable=SC2034
TASK_TITLE="Create a permanent alias"
TASK_CAT="Aliases & dotfiles"
TASK_BODY="An alias is a shortcut for a longer command:
  alias name='command'      e.g. alias ll='ls -al' makes 'll' run 'ls -al'

But an alias typed at the prompt vanishes when you close the shell. To make it
permanent, put the same alias line in a 'dotfile' that runs at every shell
start — ~/.bashrc — then reload it in your current shell with 'source ~/.bashrc'.

Your task: make 'll' a permanent alias for 'ls -al'. It has to survive opening
a new shell, so it needs to live in ~/.bashrc."
TASK_TRY=""
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
