# TAP version 14 helpers
# https://testanything.org/tap-version-14-specification.html
#
# Usage (sequential):
#   . "$XDG_CONFIG_HOME/sh/lib/tap.sh"
#   tap_plan 3
#   tap_ok "first test"
#   tap_not_ok "second test"
#   tap_ok "third test" "SKIP not supported"
#   exit "$failures"
#
# Usage (parallel collector):
#   results=$(... | xargs -P4 -n1 bash -c '...' _ || true)
#   tap_collect "$results"
#   tap_summary "validate-schema" "$quiet"

test_num=0
failures=0

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
  test_num=$((test_num + 1))
  if [ $# -gt 1 ]; then
    printf 'ok %d - %s # %s\n' "$test_num" "$1" "$2"
  else
    printf 'ok %d - %s\n' "$test_num" "$1"
  fi
}

tap_not_ok() {
  test_num=$((test_num + 1))
  failures=$((failures + 1))
  if [ $# -gt 1 ]; then
    printf 'not ok %d - %s # %s\n' "$test_num" "$1" "$2"
  else
    printf 'not ok %d - %s\n' "$test_num" "$1"
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

# Collect results from parallel workers
# Workers output: PASS <desc>, FAIL <desc>[: reason], SKIP <desc>[: reason]
_tap_collected=""

tap_collect() {
  _tap_collected="$1"
}

# Print summary from collected results and return non-zero on failure
# Usage: tap_summary "label" [quiet]
tap_summary() {
  local label="${1:-test}"
  local quiet="${2:-false}"
  local passed failed skipped

  passed=$(printf '%s\n' "$_tap_collected" | grep -c '^PASS ' || true)
  failed=$(printf '%s\n' "$_tap_collected" | grep -c '^FAIL ' || true)
  skipped=$(printf '%s\n' "$_tap_collected" | grep -c '^SKIP ' || true)

  if [ "$quiet" = false ]; then
    printf '%s\n' "$_tap_collected" | grep -E '^(PASS|FAIL|SKIP) ' || true
  fi
  if [ "$failed" -gt 0 ]; then
    printf '%s\n' "$_tap_collected" | grep -vE '^(PASS|FAIL|SKIP) ' | grep -v '^$' || true
  fi
  if [ "$quiet" != true ] && [ "$((passed + failed + skipped))" -gt 0 ]; then
    local summary="$passed passed, $failed failed"
    if [ "$skipped" -gt 0 ]; then
      summary="$summary, $skipped skipped"
    fi
    printf '%s: %s\n' "$label" "$summary"
  fi
  [ "$failed" -eq 0 ]
}
