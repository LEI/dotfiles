# shellcheck shell=bash
sshcd() {
  local host="$1"
  local dir="${SSHCD_DIR[$host]:-}"
  shift
  if [ -z "$dir" ]; then
    # shellcheck disable=SC2086
    ssh "$host" ${@:+-t "$@"}
    return
  fi
  if [ $# -eq 0 ]; then
    ssh "$host" -t "cd '$dir' && exec \$SHELL -l"
  else
    ssh "$host" -t "cd '$dir' && $*"
  fi
}

logs() {
  local name="$1"
  local lines="${2:-0}"
  local cmd="${SSHCD_LOGS[$name]:-}"
  if [ -z "$cmd" ]; then
    echo >&2 "logs: unknown host '$name'"
    echo >&2 "Available: ${!SSHCD_LOGS[*]}"
    return 1
  fi
  local fmt="${SSHCD_LOGS_FMT[$name]:-cat}"
  if [ "$lines" -gt 0 ]; then
    cmd="${cmd/tail -f/tail -f --lines="$lines"}"
  fi
  "$name" "$cmd" | $fmt
}
