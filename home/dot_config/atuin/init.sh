# Must be after starship to preserve PROMPT_COMMAND
if [ "${DISABLE_ATUIN:-0}" = "1" ]; then
  return
fi

if ! command -v atuin >/dev/null; then
  echo "init: command not found: atuin" >&2
  return
fi

eval "$(atuin init --disable-up-arrow "${SHELL##*/}")"
