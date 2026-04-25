# Must be after starship to preserve PROMPT_COMMAND

if ! command -v atuin >/dev/null; then
  echo "init: command not found: atuin" >&2
  return
fi

eval "$(atuin init --disable-up-arrow "${SHELL##*/}")"
