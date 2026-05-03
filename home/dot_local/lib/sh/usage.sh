# shellcheck shell=sh

# Render --help via `usage`, with raw #USAGE spec fallback
usage_help() {
  if ! command -v usage >/dev/null; then
    echo "${0##*/}: \`usage\` not installed, showing raw spec" >&2
    usage_spec
    return
  fi
  usage exec --help bash "$0"
}

# Print #USAGE directives without the leading prefix
usage_spec() {
  grep '^#USAGE' "$0" | sed 's/^#USAGE //'
}
