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

# Check HTTP endpoint returns expected status code
# Usage: http_check <url> [expected_status] [auth]
http_check() {
  url="$1"
  expected="${2:-200}"
  auth="${3:-}"
  code=$(curl --silent --show-error --max-time 5 -o /dev/null -w "%{http_code}" \
    ${auth:+--user "$auth"} "$url")
  if [ "$code" = "$expected" ]; then
    msg "http_check $url: ok ($code)"
    return 0
  fi
  warn "http_check $url: expected $expected, got ${code:-no response}"
  return 1
}

# Retry a command with delay between attempts
# Usage: retry <attempts> <delay> <command...>
retry() {
  attempts="$1"
  delay="$2"
  shift 2
  i=0
  while [ "$i" -lt "$attempts" ]; do
    "$@" && return 0
    i=$((i + 1))
    [ "$i" -lt "$attempts" ] && sleep "$delay"
  done
  return 1
}
