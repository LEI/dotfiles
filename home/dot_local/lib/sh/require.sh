# shellcheck shell=sh

# Fail if mise version is older than the required minimum
require_mise_version() {
  min="$1"
  ver="$(mise version --json | jq -r '.version')"
  if ! printf '%s\n%s\n' "$min" "$ver" | sort -V -C; then
    die "mise >= $min required (found ${ver:-unknown})"
  fi
  unset min ver
}
