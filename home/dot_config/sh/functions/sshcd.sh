sshcd() {
  local host="$1"
  if [ -z "$host" ]; then
    echo >&2 "sshcd: unknown host '$host'"
    echo >&2 "Available: ${!SSHCD_DIR[*]}"
    return 1
  fi
  local dir="${SSHCD_DIR[$host]:-}"
  shift
  if [ -z "$dir" ]; then
    echo >&2 "sshcd: no directory configured for host '$host'"
    return 1
  fi
  if [ $# -eq 0 ]; then
    ssh "$host" -t "cd '$dir' && exec \$SHELL -l"
  else
    ssh "$host" -t "cd '$dir' && $*"
  fi
}
