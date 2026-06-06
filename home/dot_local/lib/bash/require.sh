# shellcheck shell=bash

require_bash() {
  local min="${1:-4}" maj minor
  maj="${min%%.*}"
  minor="${min#*.}"
  [ "$minor" = "$min" ] && minor=0
  if ((BASH_VERSINFO[0] < maj || (BASH_VERSINFO[0] == maj && BASH_VERSINFO[1] < minor))); then
    printf '%s: bash %s+ required, found %s\n' "${0##*/}" "$min" "$BASH_VERSION" >&2
    exit 1
  fi
}

require_cmd() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null; then
      printf '%s: %s not found\n' "${0##*/}" "$cmd" >&2
      exit 1
    fi
  done
}
