# shellcheck shell=bash

# Helpers for validate-* and lint-* scripts

require_bash() {
  local min="${1:-4}"
  if ((BASH_VERSINFO[0] < min)); then
    echo "bash $min+ required, found $BASH_VERSION" >&2
    exit 1
  fi
}

default_jobs() {
  if [ -n "${NPROC:-}" ]; then
    echo "$NPROC"
  elif command -v nproc >/dev/null; then
    nproc
  elif command -v sysctl >/dev/null; then
    sysctl -n hw.ncpu
  else
    echo 4
  fi
}

# Render --help via the `usage` tool, falling back to "Usage: <prog> <args>"
usage_help() {
  if command -v usage >/dev/null; then
    usage exec --help bash "$0"
  else
    echo "Usage: ${0##*/}${1:+ $1}"
  fi
}

# Print this script's #USAGE directives, stripped of the prefix
usage_spec() {
  grep '^#USAGE' "$0" | sed 's/^#USAGE //'
}
