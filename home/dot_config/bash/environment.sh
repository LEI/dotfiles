HISTSIZE=100000
HISTFILESIZE=200000
# FIXME(ble.sh): arrow up should respect this setting
HISTCONTROL=erasedups:ignoreboth
HISTTIMEFORMAT="%F %T "

export EDITOR="${EDITOR:-vi -e}"
if command -v hx >/dev/null; then
  VISUAL=hx
elif command -v nvim >/dev/null; then
  VISUAL=nvim
elif command -v vim >/dev/null; then
  VISUAL=vim
elif command -v code >/dev/null; then
  VISUAL=code
else
  VISUAL="${EDITOR##/*}"
fi
export VISUAL
