if ! command -v direnv >/dev/null; then
  echo "init: command not found: direnv" >&2
  return
fi

eval "$(direnv hook "${SHELL##*/}")"
