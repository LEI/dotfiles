# shellcheck shell=bash

# Multi-format check output: default (human-friendly), tap, json
# Bars auto-detected in default mode when stdout is a terminal
# Depends on tap.sh for TAP format output (source before output.sh)
#
# Format selection (first wins):
#   1. $CHECK_FORMAT env var (default|tap|json)
#   2. --format=<fmt> in script args (consumed by output_init)
#   3. Default: default
#
# Bar selection:
#   1. $CHECK_BARS env var (auto|always|never)
#   2. --bars / --no-bars in script args (consumed by output_init)
#   3. Auto: bars when stdout is a terminal
#
# Usage:
#   . tap.sh && . output.sh && output_init "$@"
#   output_plan <count> [skip_msg]
#   output_ok <name> [directive]
#   output_not_ok <name> [directive]
#   output_bail <reason>
#   output_diag <msg>
#   output_diag_kv <label> <key=val...>
#   output_diag_json    # reads jq to_entries from stdin
#   output_bar <pct> [width=20]
#   output_finish       # returns TAP_FAILS
#
# Variables:
#   OUTPUT_FORMAT  - human|tap|json (set by init)
#   OUTPUT_BARS    - 0|1 (set by init)
#   TAP_COUNT      - test counter
#   TAP_FAILS      - failure counter

TAP_COUNT=0
TAP_FAILS=0
OUTPUT_FORMAT=""
OUTPUT_BARS=0

# Basic JSON string escaping (no jq dependency)
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r//g; s/\n/\\n/g'
}

output_init() {
  local format="" bars=""

  for arg in "$@"; do
    case "$arg" in
    --format=default) format="default" ;;
    --format=tap) format="tap" ;;
    --format=json) format="json" ;;
    --format=*) format="default" ;;
    --bars) bars="always" ;;
    --no-bars) bars="never" ;;
    esac
  done

  # Env overrides
  [ -n "${CHECK_FORMAT:-}" ] && format="$CHECK_FORMAT"
  [ -n "${CHECK_BARS:-}" ] && bars="$CHECK_BARS"

  # Auto-detect format
  [ -z "$format" ] && format="default"
  OUTPUT_FORMAT="$format"
  [ "$OUTPUT_FORMAT" != "default" ] && bars="never"

  # Auto-detect bars
  if [ -z "$bars" ]; then
    if [ -t 1 ]; then
      OUTPUT_BARS=1
    else
      OUTPUT_BARS=0
    fi
  else
    [ "$bars" = "always" ] && OUTPUT_BARS=1 || OUTPUT_BARS=0
  fi

  if [ "$OUTPUT_FORMAT" = "tap" ] && ! command -v tap_ok >/dev/null 2>&1; then
    printf 'output.sh: TAP format requires tap.sh' >&2
    exit 1
  fi
}

output_plan() {
  case "$OUTPUT_FORMAT" in
  tap)
    tap_plan "$@"
    ;;
  json)
    printf '{"type":"plan","count":%s}\n' "${1:-0}"
    ;;
  default)
    if [ "$1" -eq 0 ] && [ $# -gt 1 ]; then
      printf '[SKIP] %s\n' "$2"
    fi
    ;;
  esac
}

output_ok() {
  local name="$1" directive="${2:-}"
  case "$OUTPUT_FORMAT" in
  tap)
    if [ -n "$directive" ]; then
      tap_ok "$name" "$directive"
    else
      tap_ok "$name"
    fi
    return
    ;;
  esac
  TAP_COUNT=$((TAP_COUNT + 1))
  case "$OUTPUT_FORMAT" in
  json)
    if [ -n "$directive" ]; then
      printf '{"type":"ok","n":%d,"name":"%s","directive":"%s"}\n' \
        "$TAP_COUNT" "$(json_escape "$name")" "$(json_escape "$directive")"
    else
      printf '{"type":"ok","n":%d,"name":"%s"}\n' \
        "$TAP_COUNT" "$(json_escape "$name")"
    fi
    ;;
  default)
    if [ -n "$directive" ]; then
      case "$directive" in
      SKIP*) printf 'SKIP %s\n' "$name" ;;
      *) printf 'PASS %s %s\n' "$name" "$directive" ;;
      esac
    else
      printf 'PASS %s\n' "$name"
    fi
    ;;
  esac
}

output_not_ok() {
  local name="$1" directive="${2:-}"
  case "$OUTPUT_FORMAT" in
  tap)
    if [ -n "$directive" ]; then
      tap_not_ok "$name" "$directive"
    else
      tap_not_ok "$name"
    fi
    return
    ;;
  esac
  TAP_COUNT=$((TAP_COUNT + 1))
  TAP_FAILS=$((TAP_FAILS + 1))
  case "$OUTPUT_FORMAT" in
  json)
    if [ -n "$directive" ]; then
      printf '{"type":"not_ok","n":%d,"name":"%s","directive":"%s"}\n' \
        "$TAP_COUNT" "$(json_escape "$name")" "$(json_escape "$directive")"
    else
      printf '{"type":"not_ok","n":%d,"name":"%s"}\n' \
        "$TAP_COUNT" "$(json_escape "$name")"
    fi
    ;;
  default)
    if [ -n "$directive" ]; then
      printf 'FAIL %s %s\n' "$name" "$directive"
    else
      printf 'FAIL %s\n' "$name"
    fi
    ;;
  esac
}

output_bail() {
  case "$OUTPUT_FORMAT" in
  tap) tap_bail "$1" ;;
  json) printf '{"type":"bail","reason":"%s"}\n' "$(json_escape "$1")" ;;
  default) printf 'Bail out! %s\n' "$1" ;;
  esac
}

output_diag() {
  case "$OUTPUT_FORMAT" in
  tap) tap_diag "$1" ;;
  json) printf '{"type":"diag","msg":"%s"}\n' "$(json_escape "$1")" ;;
  default) printf '  %s\n' "$1" ;;
  esac
}

output_diag_kv() {
  local label="$1"
  shift
  local line=""
  local json_data
  json_data='{"type":"diag","label":"'"$(json_escape "$label")"'","data":{'
  local json_sep=""
  local note=""
  for kv in "$@"; do
    case "$kv" in
    \(*\))
      note="$kv"
      ;;
    *=*)
      line="$line${line:+ }$kv"
      local key="${kv%%=*}"
      local val="${kv#*=}"
      json_data="${json_data}${json_sep}\"$(json_escape "$key")\":\"$(json_escape "$val")\""
      json_sep=","
      ;;
    esac
  done
  local msg="$label: $line${note:+ $note}"
  case "$OUTPUT_FORMAT" in
  tap) tap_diag "$msg" ;;
  default) printf '  %s\n' "$msg" ;;
  json) printf '%s}}\n' "$json_data" ;;
  esac
}

output_diag_json() {
  case "$OUTPUT_FORMAT" in
  tap)
    tap_diag " ---"
    jq --raw-output 'to_entries[] | "  \(.key): \(
        if .value | type == "string" then .value | @json
        else .value end
      )"' | while IFS= read -r line; do
      tap_diag "$line"
    done
    tap_diag " ..."
    ;;
  json)
    jq --compact-output '{type:"diag",data:.}'
    ;;
  default)
    jq --raw-output 'to_entries[] | "  \(.key): \(.value)"'
    ;;
  esac
}

# output_bar <pct> [width=20]
# Standalone bar rendering, no external dependencies
# When OUTPUT_BARS=1: rendered as unicode block chars
# When OUTPUT_BARS=0: rendered as "N%"
output_bar() {
  local pct="$1" w="${2:-20}"
  if [ "$OUTPUT_BARS" = "1" ]; then
    local pct_int filled i
    pct_int="${pct%.*}"
    [ "$pct_int" -le 0 ] && pct_int=0
    [ "$pct_int" -ge 100 ] && pct_int=100
    filled=$((pct_int * w / 100))
    i=0
    while [ "$i" -lt "$filled" ]; do
      printf '█'
      i=$((i + 1))
    done
    while [ "$i" -lt "$w" ]; do
      printf '░'
      i=$((i + 1))
    done
  else
    printf '%s%%' "$pct"
  fi
}

output_finish() {
  return "$TAP_FAILS"
}
