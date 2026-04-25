if [ "${DISABLE_ZOXIDE:-0}" = "1" ]; then
  return
fi

if ! command -v zoxide >/dev/null; then
  echo "init: command not found: zoxide" >&2
  return
fi

eval "$(zoxide init "${SHELL##*/}")"
