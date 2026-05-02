# shellcheck shell=bash

# shellcheck source=home/dot_local/lib/bash/require.sh
source "${BASH_SOURCE[0]%/*}/require.sh"

# Render --help via the `usage` tool, falling back to "Usage: <prog> [args...]"
usage_help() {
  if ! command -v usage >/dev/null; then
    echo "Usage: ${0##*/}${*:+ $*}"
    return
  fi
  if ! grep -q '^#USAGE' "$0"; then
    echo "${0##*/}: no #USAGE directives in $0" >&2
    return 1
  fi
  if [ $# -gt 1 ]; then
    echo "usage_help: too many arguments" >&2
    return 2
  fi
  usage exec --help bash "$0"
}

# Print this script's #USAGE directives, stripped of the prefix
usage_spec() {
  grep '^#USAGE' "$0" | sed 's/^#USAGE //'
}
