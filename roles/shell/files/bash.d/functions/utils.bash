# Utility functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

# Test if a command exists
has() {
  hash "$1" 2>/dev/null
}

log() {
  printf "%s\n" "$*"
}

error() {
  >&2 log "$@"
  return 1
}

die() {
  error "$@"
  exit 1
}
