if command -v starship >/dev/null; then
  eval "$(starship init "${SHELL##*/}")"
fi
