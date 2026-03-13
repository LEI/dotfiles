# TODO: replace with carapace spec
if command -v zel >/dev/null; then
  return 0
fi

zel() {
  if [ $# -ne 0 ]; then
    zellij "$@"
  else
    zellij attach 0 || zellij --session 0
  fi
}

if command -v _zellij >/dev/null; then
  complete -F _zellij zel
fi
