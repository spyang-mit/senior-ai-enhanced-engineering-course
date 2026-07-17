#!/usr/bin/env bash
# The guided lesson runner. Installed on PATH as `lesson`.
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
#
# Between commands you run REAL shell commands. `lesson check` inspects the
# real result (file modes, env vars, tarballs, the backup host) — there is no
# multiple choice here, only what actually happened.

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

# Load task N (1-based): clears the contract vars, then sources the file so it
# populates TASK_TITLE/TASK_CAT/TASK_BODY/TASK_TRY/TASK_WHY/TASK_HINTS and
# defines check().
load_task() {
  local n=$1
  TASK_TITLE=; TASK_CAT=; TASK_BODY=; TASK_TRY=; TASK_WHY=; TASK_HINTS=()
  unset -f check setup 2>/dev/null || true
  # shellcheck source=/dev/null
  source "${TASKS[$((n - 1))]}"
}

show_task() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
  # A task may define setup() to prepare its starting state (e.g. create a
  # file to operate on) so it works even if the learner jumped straight here.
  # It runs only when a task is DISPLAYED, never during a check.
  declare -F setup >/dev/null && setup
  echo
  rule
  printf '%s\n' "${C_BOLD}Task ${n}/${TOTAL} · ${TASK_CAT}${C_RESET}"
  rule
  printf '%s\n\n' "$TASK_BODY"
  [ -n "$TASK_TRY" ] && printf '%s %s\n' "${C_CYAN}Try:${C_RESET}" "${C_BOLD}${TASK_TRY}${C_RESET}"
  [ -n "$TASK_WHY" ] && printf '%s %s\n' "${C_YELLOW}Why:${C_RESET}" "$TASK_WHY"
  echo
  printf '%s\n' "${C_DIM}Run the command, then: lesson check   (stuck? lesson hint)${C_RESET}"
}

do_check() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
  if check; then
    set_cur $((n + 1))
    echo
    if (( n + 1 > TOTAL )); then
      finished
    else
      printf '%s\n' "${C_GREEN}${C_BOLD}Task ${n} complete.${C_RESET} Type ${C_BOLD}lesson next${C_RESET} for what's next."
    fi
  else
    printf '%s\n' "${C_DIM}Not there yet. Try again, or: lesson hint${C_RESET}"
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
  printf '%s\n' "${C_GREEN}${C_BOLD}🎉 You finished Module 2's guided lesson.${C_RESET}"
  rule
  cat <<EOF

You can now get out of vi alive (${C_BOLD}:q!${C_RESET}), insert and edit text, jump around a
file, delete and change, undo, and yank-and-paste — the survival skills that
make git's editor (and every Unix server) stop being scary.

Next: Module 3 puts this to work — git drops you straight into vi to write
commit messages. Also try quizzes/module-2-quiz.html in your browser.

Type  lesson reset  to run the whole thing again from scratch,
or    exit          to leave the container (it self-destructs).
EOF
}

welcome() {
  clear 2>/dev/null || true
  cat <<EOF
${C_BOLD}${C_BLUE}╔══════════════════════════════════════════════════════════╗
║   Module 2 · Survival vi                                  ║
║   You are in a THROWAWAY Linux container.                ║
╚══════════════════════════════════════════════════════════╝${C_RESET}

vi is on nearly every Linux server, so it's a skill you need — even though it's
awkward at first. The one command to learn before all others: press ${C_BOLD}Esc${C_RESET}, then
type ${C_BOLD}:q!${C_RESET} and Enter to quit WITHOUT saving. You'll drill it first.
Everything here is throwaway — mangle any file, re-enter for a clean slate.

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
