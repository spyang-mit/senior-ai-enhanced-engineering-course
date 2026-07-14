#!/usr/bin/env bash
# The guided lesson runner. Installed on PATH as `lesson`.
#
# Usage from inside the sandbox:
#   lesson            show the task you're on
#   lesson next       show the task you're on (same thing, reads nicer)
#   lesson check      verify your work; on success, advance
#   lesson hint       reveal the next hint for this task
#   lesson skip       move on without checking (unblock yourself)
#   lesson reset      start the whole lesson over
#   lesson map        list every task and your progress
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
  unset -f check 2>/dev/null || true
  # shellcheck source=/dev/null
  source "${TASKS[$((n - 1))]}"
}

show_task() {
  local n; n=$(cur)
  if (( n > TOTAL )); then finished; return; fi
  load_task "$n"
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
  printf '%s\n' "${C_GREEN}${C_BOLD}🎉 You finished Module 1's guided lesson.${C_RESET}"
  rule
  cat <<EOF

You navigated a real Unix filesystem, bent its permissions to your will,
moved bytes with tar and scp over ssh, and built an audited backup script —
all in a container you can throw away without a second thought.

Next: the graded project in README.md, and quizzes/module-1-quiz.md.

Type  lesson reset  to run the whole thing again from scratch.
EOF
}

welcome() {
  clear 2>/dev/null || true
  cat <<EOF
${C_BOLD}${C_BLUE}╔══════════════════════════════════════════════════════════╗
║   Module 1 · The command line & your environment         ║
║   You are in a THROWAWAY Linux container.                ║
╚══════════════════════════════════════════════════════════╝${C_RESET}

Nothing you do here can touch your real machine. Break things freely —
${C_BOLD}rm -rf${C_RESET} whatever you like; exit and re-enter for a clean slate.

Your guide is the ${C_BOLD}lesson${C_RESET} command:

  ${C_BOLD}lesson next${C_RESET}    what to do next        ${C_BOLD}lesson hint${C_RESET}   a nudge
  ${C_BOLD}lesson check${C_RESET}   verify your work       ${C_BOLD}lesson map${C_RESET}    see all tasks
  ${C_BOLD}lesson skip${C_RESET}    move on anyway         ${C_BOLD}lesson reset${C_RESET}  start over

Type ${C_BOLD}lesson next${C_RESET} to begin.
EOF
}

case "${1:-next}" in
  next | task | status | "") show_task ;;
  check)                     do_check ;;
  hint)                      do_hint ;;
  skip)                      set_cur $(( $(cur) + 1 )); info "Skipped."; show_task ;;
  map | list)                do_map ;;
  reset)                     set_cur 1; info "Lesson reset."; show_task ;;
  welcome | start)           welcome ;;
  *) echo "Unknown: $1"; echo "Try: lesson next | check | hint | skip | map | reset"; exit 2 ;;
esac
