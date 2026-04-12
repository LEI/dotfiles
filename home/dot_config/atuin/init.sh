# Must be after starship to preserve PROMPT_COMMAND
if command -v atuin >/dev/null; then
  eval "$(atuin init --disable-up-arrow "${SHELL##*/}")"
fi
