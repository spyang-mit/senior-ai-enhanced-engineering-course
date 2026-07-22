#!/usr/bin/env bash
# The guided lesson runner for Module 5. Installed on PATH as `lesson`.
#
#   lesson            show the task you're on
#   lesson next       same thing, reads nicer
#   lesson check      verify your work (or answer its question); on success, advance
#   lesson hint       reveal the next hint for this task
#   lesson skip       move on without checking
#   lesson jump N     go straight to task N
#   lesson reset      start the whole lesson over
#   lesson map        list every task and your progress
#
# You EDIT code in the mounted ~/workspace folder (from your host, with your AI/
# editor). You RUN `lesson` here in the container. `lesson check` exercises your
# handler through a battery of real requests -- good input, bad input, forged
# fields, retries -- and reports exactly which behaviors pass.

set -uo pipefail

LESSON_HOME=/opt/lesson
TASK_DIR="$LESSON_HOME/tasks"
STATE_DIR="$HOME/.lesson"
STATE_FILE="$STATE_DIR/current"
HINT_FILE="$STATE_DIR/hint"
QUIZPROG_FILE="$STATE_DIR/quizprog"   # how many of this task's questions are answered

# shellcheck source=/dev/null
source "$LESSON_HOME/lib/ui.sh"
# shellcheck source=/dev/null
source "$LESSON_HOME/lib/checks.sh"

mapfile -t TASKS < <(printf '%s\n' "$TASK_DIR"/[0-9]*.sh | sort)
TOTAL=${#TASKS[@]}

mkdir -p "$STATE_DIR"
[ -f "$STATE_FILE" ] || echo 1 > "$STATE_FILE"

cur() { cat "$STATE_FILE"; }
set_cur() { echo "$1" > "$STATE_FILE"; echo 0 > "$HINT_FILE"; echo 0 > "$QUIZPROG_FILE"; }

load_task() {
  local n=$1
  TASK_TITLE=; TASK_CAT=; TASK_BODY=; TASK_TRY=; TASK_WHY=; TASK_GOAL=; TASK_HINTS=()
  TASK_QUIZ=; TASK_QUIZ_OPTIONS=(); TASK_QUIZ_ANSWER=; TASK_QUIZ_EXPLAIN=
  unset -f check setup quiz 2>/dev/null || true
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
  # The concrete deliverable, highlighted so it doesn't get lost in the prose.
  [ -n "$TASK_GOAL" ] && printf '\n%s %s\n' "${C_MAGENTA}${C_BOLD}▸ GOAL:${C_RESET}" "${C_BOLD}${TASK_GOAL}${C_RESET}"
  echo
  if declare -F quiz >/dev/null || [ -n "$TASK_QUIZ" ]; then
    printf '%s\n' "${C_DIM}When you're ready, run: lesson check   — it'll ask you some questions. (stuck? lesson hint)${C_RESET}"
  else
    printf '%s\n' "${C_DIM}Do the work, then: lesson check   (stuck? lesson hint)${C_RESET}"
  fi
}

do_check() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
  if declare -F quiz >/dev/null; then
    do_quiz_multi "$n"; return
  fi
  if [ -n "$TASK_QUIZ" ]; then
    do_quiz "$n"; return
  fi
  if check; then
    _advance "$n"
  else
    printf '%s\n' "${C_DIM}Not there yet. Try again, or: lesson hint${C_RESET}"
    return 1
  fi
}

# A multi-question task defines quiz(), which calls ask() once per question.
# Progress persists across `lesson check` runs, so a wrong answer only re-asks
# THAT question next time — you never redo the ones you already got right.
do_quiz_multi() {
  local n=$1
  QUIZ_IDX=0
  QUIZ_PROGRESS=$(cat "$QUIZPROG_FILE" 2>/dev/null || echo 0)
  QUIZ_FAILED=0
  quiz
  local total=$QUIZ_IDX
  echo "$QUIZ_PROGRESS" > "$QUIZPROG_FILE"
  if (( QUIZ_FAILED == 0 && QUIZ_PROGRESS >= total )); then
    _advance "$n"
  else
    echo
    printf '%s\n' "${C_DIM}Answered ${QUIZ_PROGRESS}/${total}. Run ${C_BOLD}lesson check${C_RESET}${C_DIM} to pick up where you left off (or ${C_BOLD}lesson hint${C_RESET}${C_DIM}).${C_RESET}"
    return 1
  fi
}

# ask <question> <opt1> <opt2> ... <optN> <answer-1-based> <explanation>
# Asks only questions not yet answered; stops at the first wrong one this run.
ask() {
  local q="$1"; shift
  local args=("$@") count=${#args[@]}
  local explain="${args[$((count - 1))]}"
  local answer="${args[$((count - 2))]}"
  local nopts=$((count - 2))
  local opts=("${args[@]:0:nopts}")
  local i=$QUIZ_IDX
  QUIZ_IDX=$((QUIZ_IDX + 1))
  (( QUIZ_FAILED )) && return          # already missed one this run
  (( i < QUIZ_PROGRESS )) && return    # already answered correctly before
  echo
  printf '%s %s\n' "${C_CYAN}Q$((i + 1)):${C_RESET}" "${C_BOLD}${q}${C_RESET}"
  local j letter
  for j in "${!opts[@]}"; do
    letter=$(printf "\\$(printf '%03o' $((97 + j)))")
    printf '  %s) %s\n' "$letter" "${opts[$j]}"
  done
  printf '%s' "Your answer: "
  local reply; read -r reply || true
  reply="$(printf '%s' "$reply" | tr 'A-Z' 'a-z' | tr -d '[:space:]')"
  local want; want=$(printf "\\$(printf '%03o' $((97 + answer - 1)))")
  if [ "$reply" = "$want" ] || [ "$reply" = "$answer" ]; then
    printf '%s %s\n' "${C_GREEN}✓ Correct.${C_RESET}" "$explain"
    QUIZ_PROGRESS=$((i + 1))
  else
    printf '%s\n' "${C_RED}✗ Not quite.${C_RESET} ${C_DIM}Re-read the task or try lesson hint, then run lesson check to try this one again.${C_RESET}"
    QUIZ_FAILED=1
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

You now own the contract and the trust boundary: you can author an OpenAPI
contract, make a server conform to it, and defend it against a hostile client.
The senior habits you drilled — validate at the boundary, never trust the client
(price, status, ownership), make writes idempotent so retries are safe, return
honest status codes, and paginate — are what separate a backend that survives
from one that silently corrupts.

Next: the capstone in README.md — design and build one endpoint from the
contract, proven by the conformance harness. Then try the quizzes.

Type  lesson reset  to run it again, or  exit  to leave (the container self-destructs).
EOF
}

welcome() {
  clear 2>/dev/null || true
  cat <<EOF
${C_BOLD}${C_BLUE}╔══════════════════════════════════════════════════════════╗
║   Module 5 · APIs, contracts & the client/server boundary ║
║   You are in a THROWAWAY Linux container.                 ║
╚══════════════════════════════════════════════════════════╝${C_RESET}

A deliberately-flawed ${C_BOLD}orders API${C_RESET} is running at ${C_BOLD}http://localhost:8080${C_RESET} — curl it
to see the bugs. You OWN the contract (${C_BOLD}~/workspace/orders-api.yaml${C_RESET}) and you
harden the server by editing files in ${C_BOLD}~/workspace/${C_RESET}.

${C_BOLD}Two terminals:${C_RESET}
  • THIS one (in the container): run ${C_BOLD}lesson${C_RESET} and ${C_BOLD}curl${C_RESET}.
  • On your HOST, in the mounted ${C_BOLD}workspace/${C_RESET} folder: open your editor / AI and
    write the code. Edits appear here instantly. Your code lives in a folder you
    own — nuking this container never loses it.

Your guide is the ${C_BOLD}lesson${C_RESET} command:

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
