# shellcheck shell=bash disable=SC2034
TASK_TITLE="Keep secrets out of git"
TASK_CAT="Environment variables"
TASK_BODY="Look at secret.env (cat secret.env) — it holds fake
API keys and a database password. Apps load config like this from a '.env'
file at startup.

Rule: a .env / secrets file NEVER goes into git. The way you enforce that is
a .gitignore file listing what git must ignore. Create one in your playground
that ignores the secret:"
TASK_TRY="echo 'secret.env' > .gitignore"
TASK_WHY="Leaked credentials in a public git repo are one of the most common
real-world breaches — bots scan GitHub for them within seconds of a push.
'.gitignore' is the cheap, boring habit that prevents it."
TASK_HINTS=(
  "Create .gitignore containing the line 'secret.env'."
  "Run: echo 'secret.env' > .gitignore"
)
check() {
  local f="$HOME/playground/.gitignore"
  if file_contains "$f" "secret.env"; then
    pass ".gitignore now excludes secret.env — it won't get committed."
  else
    fail "add 'secret.env' to .gitignore"; return 1
  fi
}
