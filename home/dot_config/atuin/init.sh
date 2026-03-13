# Must be after starship to preserve PROMPT_COMMAND
if ! command -v atuin >/dev/null; then
  echo >&2 "Command 'atuin' not found"
  return 0
fi

eval "$(atuin init --disable-up-arrow "$shell")"
