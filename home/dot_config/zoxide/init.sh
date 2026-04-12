if command -v zoxide >/dev/null; then
  eval "$(zoxide init "${SHELL##*/}")"
fi
