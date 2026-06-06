# shellcheck shell=sh
#
# Logging helpers using GNU-style "<prog>: [<level>: ]<message>".

# case "${CHEZMOI_TRACE:-}" in 1 | true) set -x ;; esac

: "${lib_dir:=$HOME/.local/lib}"
# shellcheck source=home/dot_local/lib/sh/redact.sh
. "$lib_dir/sh/redact.sh"

# Write a raw line to stderr
msg() {
  printf '%s\n' "$*" >&2
}

# Basename of the calling script, used as the log prefix
log_prefix() {
  printf '%s' "${0##*/}"
}

# Print "<prog>: <message>" to stderr
info() {
  msg "$(log_prefix): $*"
}

# Deprecated: shadows macOS /usr/bin/log; prefer info()
log() {
  info "$@"
}

# Print "<prog>: warning: <message>" to stderr
warn() {
  msg "$(log_prefix): warning: $*"
}

# Print "<prog>: error: <message>" to stderr
err() {
  msg "$(log_prefix): error: $*"
}

# Single-quote an argument for shell, only when it contains special characters
quote_arg() {
  case $1 in
  '' | *[!a-zA-Z0-9_/.@%+=:,-]*)
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
    ;;
  *)
    printf '%s' "$1"
    ;;
  esac
}

# Quote each argument and join with spaces
quote_args() {
  quote_args_out=
  for quote_args_arg; do
    quote_args_out="$quote_args_out $(quote_arg "$quote_args_arg")"
  done
  printf '%s' "${quote_args_out# }"
}

# Echo "+ <quoted args>" with secret-looking NAME=value args redacted, then run
trace() {
  trace_out=
  for trace_arg; do
    trace_out="$trace_out $(quote_arg "$(redact_arg "$trace_arg")")"
  done
  msg "+${trace_out}"
  "$@"
}
