# shellcheck shell=bash

# Print to stderr
msg() {
  printf '%s\n' "$*" >&2
}

# Output the script name
log_prefix() {
  printf '%s' "${0##*/}"
}

# Prefixed progress
log() {
  msg "$(log_prefix): $*"
}

# Prefixed warning
warn() {
  msg "$(log_prefix): warning: $*"
}

# Set ERR trap to log the failing line number
err_trap() {
  trap 'log "error at line $LINENO"' ERR
}

# Quote shell-special args (POSIX-safe)
quote_args() {
  _quoted=
  for _arg; do
    case $_arg in
    '' | *[!a-zA-Z0-9_/.@%+=:,-]*)
      _arg="'$(printf '%s' "$_arg" | sed "s/'/'\\\\''/g")'"
      ;;
    esac
    _quoted="$_quoted $_arg"
  done
  printf '%s' "${_quoted# }"
}

# Echo and run
trace() {
  msg "+ $(quote_args "$@")"
  "$@"
}
