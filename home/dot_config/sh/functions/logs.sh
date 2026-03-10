logs() {
  local name="$1"
  local lines="${2:-0}"
  local cmd="${SSHCD_LOGS["$name"]:-}"
  if [ -z "$cmd" ]; then
    echo >&2 "logs: unknown host '$name'"
    echo >&2 "Available: ${!SSHCD_LOGS[*]}"
    return 1
  fi
  local fmt="${SSHCD_LOGS_FMT["$name"]:-cat}"
  if [ "$lines" -gt 0 ] 2>/dev/null; then
    cmd="${cmd/tail -f/tail -f --lines="$lines"}"
  fi
  sshcd "$name" "$cmd" | $fmt
}
