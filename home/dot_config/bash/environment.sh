HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT="%F %T "

if command -v hx >/dev/null; then
  EDITOR=hx
elif command -v nvim >/dev/null; then
  EDITOR=nvim
else
  EDITOR="${EDITOR:-vi}"
fi

export EDITOR
export VISUAL="${VISUAL:-$EDITOR}"
