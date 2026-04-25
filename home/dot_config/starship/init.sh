if [ "${DISABLE_STARSHIP:-0}" = "1" ]; then
  return
fi

if ! command -v starship >/dev/null; then
  echo "init: command not found: starship" >&2
  return
fi

eval "$(starship init "${SHELL##*/}")"
