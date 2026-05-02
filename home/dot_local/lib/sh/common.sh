# shellcheck shell=sh

# Print to stderr
msg() {
  printf '%s\n' "$*" >&2
}

# Prefixed progress
log() {
  msg "${0##*/}: $*"
}

# Prefixed warning
warn() {
  msg "${0##*/}: warning: $*"
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
