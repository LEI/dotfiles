# TODO: replace with carapace spec
if ! command -v zellij >/dev/null; then
  echo "init: command not found: zellij" >&2
  return
fi

zel() {
  if [ $# -ne 0 ]; then
    zellij "$@"
  else
    zellij attach 0 || zellij --session 0
  fi
}

# TODO: replace with carapace spec
# if [ "${SHELL##*/}" = bash ] && command -v _zellij >/dev/null; then
#   complete -F _zellij zel
# fi
