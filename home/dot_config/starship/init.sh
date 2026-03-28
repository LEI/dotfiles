# shellcheck disable=SC2154
if ! command -v starship >/dev/null; then
  echo >&2 "Command 'starship' not found"
  return 0
fi

eval "$(starship init "$shell")"
