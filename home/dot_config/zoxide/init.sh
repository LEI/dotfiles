if ! command -v zoxide >/dev/null; then
  echo >&2 "Command 'zoxide' not found"
  return 0
fi

eval "$(zoxide init "$shell")"
