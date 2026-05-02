# shellcheck shell=bash

# Aggregate parallel-worker output and emit human or TAP summaries
#
# Worker protocol (one line per test, prefix-tagged):
#   PASS <desc>
#   FAIL <desc>
#   SKIP <desc> [# <reason>]
# Unprefixed lines after a FAIL become TAP diagnostics
#
# Usage:
#   results=$(... | xargs -0 -P4 -n1 bash -c '...' _ || true)
#   report_collect "$results"
#   report_human "$prog" "$verbosity" # default
#   report_tap "$prog" # pipeable to TAP consumers like prove or tap2junit

report_data=""

report_collect() {
  report_data="$1"
}

# Human-readable summary (matches the validate-schema legacy contract)
# verbosity: 0 fail-only no summary, 1 fail-only + summary (default), 2 all + summary
report_human() {
  local label="${1:-test}"
  local verbosity="${2:-1}"
  local passed failed skipped

  passed=$(printf '%s\n' "$report_data" | grep -c '^PASS ' || [ $? -eq 1 ])
  failed=$(printf '%s\n' "$report_data" | grep -c '^FAIL ' || [ $? -eq 1 ])
  skipped=$(printf '%s\n' "$report_data" | grep -c '^SKIP ' || [ $? -eq 1 ])

  if [ "$verbosity" -ge 2 ]; then
    printf '%s\n' "$report_data" | grep -E '^(PASS|FAIL|SKIP) ' || [ $? -eq 1 ]
  else
    printf '%s\n' "$report_data" | grep -E '^FAIL ' || [ $? -eq 1 ]
  fi
  if [ "$failed" -gt 0 ]; then
    printf '%s\n' "$report_data" | grep -vE '^(PASS|FAIL|SKIP) ' | grep -v '^$' || [ $? -eq 1 ]
  fi
  if [ "$verbosity" -ge 1 ] && [ "$((passed + failed + skipped))" -gt 0 ]; then
    printf '%s: %d passed, %d failed, %d skipped\n' "$label" "$passed" "$failed" "$skipped" >&2
  fi
  [ "$failed" -eq 0 ]
}

# TAP version 14 emitter; PASS/FAIL/SKIP -> ok/not ok/ok # SKIP, with sequential plan
# Diagnostic lines (unprefixed text after a FAIL) emit as `# <line>` per spec
report_tap() {
  local label="${1:-test}"
  local passed failed skipped total n=0
  local line desc in_diag=false

  passed=$(printf '%s\n' "$report_data" | grep -c '^PASS ' || [ $? -eq 1 ])
  failed=$(printf '%s\n' "$report_data" | grep -c '^FAIL ' || [ $? -eq 1 ])
  skipped=$(printf '%s\n' "$report_data" | grep -c '^SKIP ' || [ $? -eq 1 ])
  total=$((passed + failed + skipped))

  printf 'TAP version 14\n1..%d\n' "$total"
  while IFS= read -r line; do
    case "$line" in
    'PASS '*)
      in_diag=false
      n=$((n + 1))
      desc="${line#PASS }"
      printf 'ok %d - %s\n' "$n" "$desc"
      ;;
    'FAIL '*)
      in_diag=true
      n=$((n + 1))
      desc="${line#FAIL }"
      printf 'not ok %d - %s\n' "$n" "$desc"
      ;;
    'SKIP '*)
      in_diag=false
      n=$((n + 1))
      rest="${line#SKIP }"
      case "$rest" in
      *' # '*)
        printf 'ok %d - %s # SKIP %s\n' "$n" "${rest% # *}" "${rest#* # }"
        ;;
      *)
        printf 'ok %d - %s # SKIP\n' "$n" "$rest"
        ;;
      esac
      ;;
    '')
      ;;
    *)
      if [ "$in_diag" = true ]; then
        printf '# %s\n' "$line"
      fi
      ;;
    esac
  done < <(printf '%s\n' "$report_data")
  printf '# %s: %d passed, %d failed, %d skipped\n' "$label" "$passed" "$failed" "$skipped"
  [ "$failed" -eq 0 ]
}
