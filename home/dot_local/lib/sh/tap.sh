# shellcheck shell=sh

# TAP version 14 helpers
# https://testanything.org/tap-version-14-specification.html
#
# Usage:
#   . "$HOME/.local/lib/sh/tap.sh"
#   tap_plan 3
#   tap_ok "first test"
#   tap_not_ok "second test"
#   tap_ok "third test" "SKIP not supported"
#   exit "$TAP_FAILS"

TAP_COUNT=0
TAP_FAILS=0

tap_plan() {
  if [ "$1" -eq 0 ] && [ $# -gt 1 ]; then
    printf 'TAP version 14\n1..0 # SKIP %s\n' "$2"
  else
    printf 'TAP version 14\n1..%s\n' "$1"
  fi
}

tap_bail() {
  printf 'Bail out! %s\n' "$1"
}

tap_ok() {
  TAP_COUNT=$((TAP_COUNT + 1))
  if [ $# -gt 1 ]; then
    printf 'ok %d - %s # %s\n' "$TAP_COUNT" "$1" "$2"
  else
    printf 'ok %d - %s\n' "$TAP_COUNT" "$1"
  fi
}

tap_not_ok() {
  TAP_COUNT=$((TAP_COUNT + 1))
  TAP_FAILS=$((TAP_FAILS + 1))
  if [ $# -gt 1 ]; then
    printf 'not ok %d - %s # %s\n' "$TAP_COUNT" "$1" "$2"
  else
    printf 'not ok %d - %s\n' "$TAP_COUNT" "$1"
  fi
}

tap_diag() {
  printf '# %s\n' "$1"
}

# YAML diagnostic block from key=value pairs
tap_diag_kv() {
  printf '  ---\n'
  for kv in "$@"; do
    printf '  %s\n' "$kv"
  done
  printf '  ...\n'
}

# YAML diagnostic block from JSON (pipe jq output)
tap_diag_json() {
  printf '  ---\n'
  jq --raw-output 'to_entries[] | "  \(.key): \(
    if .value | type == "string" then .value | @json
    else .value end
  )"'
  printf '  ...\n'
}
