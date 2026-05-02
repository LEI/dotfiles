# shellcheck shell=bash

require_bash() {
  local min="${1:-4}"
  if ((BASH_VERSINFO[0] < min)); then
    echo "bash $min+ required, found $BASH_VERSION" >&2
    exit 1
  fi
}
