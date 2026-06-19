# shellcheck shell=sh

# Render --help via `usage`, with raw #USAGE spec fallback
usage_help() {
  if command -v usage >/dev/null && rendered="$(usage exec --help bash "$0")" && [ -n "$rendered" ]; then
    printf '%s\n' "$rendered"
  else
    printf 'Usage: %s %s\n' "${0##*/}" "${1:-}"
  fi
  unset rendered
}

# Print #USAGE directives without the leading prefix
usage_spec() {
  grep '^#USAGE' "$0" | sed 's/^#USAGE //'
}
