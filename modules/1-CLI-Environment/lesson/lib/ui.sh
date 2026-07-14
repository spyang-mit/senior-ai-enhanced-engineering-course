# shellcheck shell=bash
# Small presentation helpers for the lesson runner. Sourced, never run directly.

if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_CYAN=$'\033[36m'
else
  C_RESET=; C_BOLD=; C_DIM=; C_GREEN=; C_RED=; C_YELLOW=; C_BLUE=; C_CYAN=
fi

rule() { printf '%s\n' "${C_DIM}────────────────────────────────────────────────────────────${C_RESET}"; }

# pass / fail are called from a task's check() to report the real result.
pass() { printf '%s\n' "${C_GREEN}✓ ${C_RESET}$*"; }
fail() { printf '%s\n' "${C_RED}✗ ${C_RESET}$*"; }
info() { printf '%s\n' "${C_CYAN}$*${C_RESET}"; }
