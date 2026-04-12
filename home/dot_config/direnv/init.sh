if command -v direnv >/dev/null; then
  eval "$(direnv hook "${SHELL##*/}")"
fi
