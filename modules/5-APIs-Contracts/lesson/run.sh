#!/usr/bin/env bash
# The guided lesson runner for Module 5. Installed on PATH as `lesson`.
#
# Usage from inside the sandbox:
#   lesson            show the task you're on
#   lesson next       show the task you're on (same thing, reads nicer)
#   lesson check      verify your work; on success, advance
#   lesson hint       reveal the next hint for this task
#   lesson skip       move on without checking (unblock yourself)
#   lesson jump N     go straight to task N (handy for testing/review)
#   lesson reset      start the whole lesson over
#   lesson map        list every task and your progress
#
# Type `exit` at any time to leave the container (it self-destructs).

set -uo pipefail

LESSON_HOME=/opt/lesson
TASK_DIR="$LESSON_HOME/tasks"
STATE_DIR="$HOME/.lesson"
STATE_FILE="$STATE_DIR/current"
HINT_FILE="$STATE_DIR/hint"

# shellcheck source=/dev/null
source "$LESSON_HOME/lib/ui.sh"
# shellcheck source=/dev/null
source "$LESSON_HOME/lib/checks.sh"

mapfile -t TASKS < <(printf '%s\n' "$TASK_DIR"/[0-9]*.sh | sort)
TOTAL=${#TASKS[@]}

mkdir -p "$STATE_DIR"
[ -f "$STATE_FILE" ] || echo 1 > "$STATE_FILE"

cur() { cat "$STATE_FILE"; }
set_cur() { echo "$1" > "$STATE_FILE"; echo 0 > "$HINT_FILE"; }

load_task() {
  local n=$1
  TASK_TITLE=; TASK_CAT=; TASK_BODY=; TASK_TRY=; TASK_WHY=; TASK_GOAL=; TASK_HINTS=()
  TASK_QUIZ=; TASK_QUIZ_OPTIONS=(); TASK_QUIZ_ANSWER=; TASK_QUIZ_EXPLAIN=
  unset -f check setup 2>/dev/null || true
  # shellcheck source=/dev/null
  source "${TASKS[$((n - 1))]}"
}

_advance() {
  local n=$1
  set_cur $((n + 1))
  echo
  if (( n + 1 > TOTAL )); then
    finished
  else
    printf '%s\n' "${C_GREEN}${C_BOLD}Task ${n} complete.${C_RESET} Type ${C_BOLD}lesson next${C_RESET} for what's next."
  fi
}

show_task() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
  declare -F setup >/dev/null && setup
  echo
  rule
  printf '%s\n' "${C_BOLD}Task ${n}/${TOTAL} · ${TASK_CAT}${C_RESET}"
  rule
  printf '%s\n\n' "$TASK_BODY"
  [ -n "$TASK_TRY" ] && printf '%s %s\n' "${C_CYAN}Try:${C_RESET}" "${C_BOLD}${TASK_TRY}${C_RESET}"
  [ -n "$TASK_WHY" ] && printf '%s %s\n' "${C_YELLOW}Why:${C_RESET}" "$TASK_WHY"
  [ -n "$TASK_GOAL" ] && printf '\n%s %s\n' "${C_MAGENTA}${C_BOLD}▸ GOAL:${C_RESET}" "${C_BOLD}${TASK_GOAL}${C_RESET}"
  echo
  if [ "${PWD:-}" != "$HOME/playground" ]; then
    printf '%s\n' "${C_YELLOW}⚠  Your shell isn't in the playground. Run:  cd ~/playground${C_RESET}"
  fi
  if [ -n "$TASK_QUIZ" ]; then
    printf '%s\n' "${C_DIM}When you're ready, run: lesson check   — it'll ask you a question. (stuck? lesson hint)${C_RESET}"
  else
    printf '%s\n' "${C_DIM}Run the command, then: lesson check   (stuck? lesson hint)${C_RESET}"
  fi
}

do_check() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
  if [ -n "$TASK_QUIZ" ]; then
    do_quiz "$n"; return
  fi
  # For tasks that need the server (not pure YAML/quiz tasks), restart it first
  # so it picks up edited handler files.
  if declare -F needs_server >/dev/null && needs_server; then
    restart_server || return 1
  fi
  if check; then
    _advance "$n"
  else
    printf '%s\n' "${C_DIM}Not there yet. Try again, or: lesson hint${C_RESET}"
    return 1
  fi
}

do_quiz() {
  local n=$1 i letter reply
  echo
  printf '%s\n' "${C_BOLD}${TASK_QUIZ}${C_RESET}"
  for i in "${!TASK_QUIZ_OPTIONS[@]}"; do
    letter=$(printf "\\$(printf '%03o' $((97 + i)))")
    printf '  %s) %s\n' "$letter" "${TASK_QUIZ_OPTIONS[$i]}"
  done
  printf '%s' "Your answer: "
  read -r reply || true
  reply="$(printf '%s' "$reply" | tr 'A-Z' 'a-z' | tr -d '[:space:]')"
  local want_letter; want_letter=$(printf "\\$(printf '%03o' $((97 + TASK_QUIZ_ANSWER - 1)))")
  if [ "$reply" = "$want_letter" ] || [ "$reply" = "$TASK_QUIZ_ANSWER" ]; then
    printf '%s %s\n' "${C_GREEN}✓ Correct.${C_RESET}" "$TASK_QUIZ_EXPLAIN"
    _advance "$n"
  else
    printf '%s\n' "${C_RED}✗ Not quite.${C_RESET} Re-read the task or try ${C_BOLD}lesson hint${C_RESET}, then run ${C_BOLD}lesson check${C_RESET} to answer again."
    return 1
  fi
}

do_hint() {
  local n; n=$(cur)
  (( n > TOTAL )) && { finished; return; }
  load_task "$n"
  local h; h=$(cat "$HINT_FILE" 2>/dev/null || echo 0)
  local count=${#TASK_HINTS[@]}
  if (( count == 0 )); then info "No hints for this one — re-read the task."; return; fi
  if (( h >= count )); then h=$((count - 1)); fi
  printf '%s %s\n' "${C_YELLOW}Hint:${C_RESET}" "${TASK_HINTS[$h]}"
  (( h + 1 < count )) && echo "$((h + 1))" > "$HINT_FILE"
}

do_map() {
  local n; n=$(cur)
  echo
  printf '%s\n' "${C_BOLD}Your progress${C_RESET}"
  local i
  for (( i = 1; i <= TOTAL; i++ )); do
    load_task "$i"
    local mark
    if (( i < n )); then mark="${C_GREEN}✓${C_RESET}"
    elif (( i == n )); then mark="${C_CYAN}▶${C_RESET}"
    else mark="${C_DIM}·${C_RESET}"; fi
    printf ' %b %2d  %s\n' "$mark" "$i" "$TASK_TITLE"
  done
  echo
}

finished() {
  echo
  rule
  printf '%s\n' "${C_GREEN}${C_BOLD}🎉 You finished Module 5's guided lesson.${C_RESET}"
  rule
  cat <<EOF

You authored a full OpenAPI contract, hardened a server against exploit after
exploit, added idempotency, pagination, and authorization, and built one write
path from scratch — conformance-harness verified. You own the contract now.

Next: the project in README.md — and the quizzes. Then Module 6: data modeling
and integrity, where the same contract-and-verify discipline meets databases.

Type  lesson reset  to run the whole thing again from scratch,
or    exit          to leave the container (it self-destructs).
EOF
}

welcome() {
  clear 2>/dev/null || true
  cat <<EOF
${C_BOLD}${C_BLUE}╔══════════════════════════════════════════════════════════╗
║   Module 5 · APIs, contracts & the client/server boundary ║
╚══════════════════════════════════════════════════════════╝${C_RESET}

The orders API is running at ${C_BOLD}http://localhost:8080${C_RESET}.
The contract is in ${C_BOLD}workspace/orders-api.yaml${C_RESET} (on your host machine).
Handler code lives in ${C_BOLD}workspace/handlers/${C_RESET}.

Two-terminal workflow:
  1. ${C_BOLD}lesson next${C_RESET}   — read the task in this container
  2. On your HOST: edit workspace/handlers/ via AI or editor
  3. ${C_BOLD}lesson check${C_RESET}  — restarts the server, verifies the result

${C_BOLD}lesson${C_RESET} commands:

  ${C_BOLD}lesson next${C_RESET}    what to do next        ${C_BOLD}lesson hint${C_RESET}     a nudge
  ${C_BOLD}lesson check${C_RESET}   verify your work       ${C_BOLD}lesson map${C_RESET}      see all tasks
  ${C_BOLD}lesson skip${C_RESET}    move on anyway         ${C_BOLD}lesson jump N${C_RESET}   go to task N
  ${C_BOLD}lesson reset${C_RESET}   start over             ${C_BOLD}exit${C_RESET}            leave (self-destructs)

Type ${C_BOLD}lesson next${C_RESET} to begin.
EOF
}

case "${1:-next}" in
  next | task | status | "") show_task ;;
  check)                     do_check ;;
  hint)                      do_hint ;;
  skip)                      set_cur $(( $(cur) + 1 )); info "Skipped."; show_task ;;
  map | list)                do_map ;;
  jump)
    n="${2:-}"
    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= TOTAL )); then
      set_cur "$n"; info "Jumped to task $n."; show_task
    else
      echo "Usage: lesson jump <1-$TOTAL>"; exit 2
    fi
    ;;
  reset)                     set_cur 1; info "Lesson reset."; show_task ;;
  welcome | start)           welcome ;;
  *) echo "Unknown: $1"; echo "Try: lesson next | check | hint | skip | map | reset"; exit 2 ;;
esac
