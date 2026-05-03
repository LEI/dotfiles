# shellcheck shell=sh

# Check if value is truthy (1 or true)
truthy() {
  case "$1" in
  1 | true) return 0 ;;
  *) return 1 ;;
  esac
}

# Check if command exists in PATH
has() {
  command -v "$@" >/dev/null 2>&1
}

# Print prefixed error to stderr and exit
die() {
  warn "$@"
  exit 1
}

# Log command to stderr when verbose, then execute
run() {
  if truthy "${CHEZMOI_VERBOSE:-}"; then
    trace "$@"
  else
    "$@"
  fi
}

# Like run but skip execution in dry run mode
dry_run() {
  if truthy "${DRY_RUN:-}"; then
    msg "DRY-RUN: $*"
    return 0
  fi
  run "$@"
}
