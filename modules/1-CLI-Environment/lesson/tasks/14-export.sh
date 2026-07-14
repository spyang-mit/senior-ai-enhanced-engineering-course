# shellcheck shell=bash disable=SC2034
TASK_TITLE="Export a variable"
TASK_CAT="Environment variables"
TASK_BODY="There's a difference between a shell variable and an environment
variable:
  NAME=value          exists only in THIS shell
  export NAME=value   is passed down to every program the shell launches

Programs (and scripts) only see EXPORTED variables. Export one that a deploy
script might read — name it DEPLOY_ENV with the value staging:"
TASK_TRY="export DEPLOY_ENV=staging"
TASK_WHY="This is why 'export' matters: the 'lesson' command you're about to
run is a child process, and it can only see DEPLOY_ENV because you exported
it. Forget the export, and your script gets an empty value."
TASK_HINTS=(
  "Use the export keyword, no spaces around the '='."
  "Run: export DEPLOY_ENV=staging"
)
check() {
  if env_is DEPLOY_ENV staging; then
    pass "DEPLOY_ENV=staging is exported — this child process can see it."
  else
    if env_set DEPLOY_ENV; then
      fail "DEPLOY_ENV is '$DEPLOY_ENV'; it should be exactly 'staging'"
    else
      fail "I don't see DEPLOY_ENV — did you 'export' it (not just set it)?"
    fi
    return 1
  fi
}
