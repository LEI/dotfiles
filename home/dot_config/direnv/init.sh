# shellcheck disable=SC2154
if ! command -v direnv >/dev/null; then
  echo >&2 "Command 'direnv' not found"
  return 0
fi

eval "$(direnv hook "$shell")"
