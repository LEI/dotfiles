# shellcheck shell=sh

if command -v nvim >/dev/null; then
  alias dbui="nvim +DBUI"
fi
