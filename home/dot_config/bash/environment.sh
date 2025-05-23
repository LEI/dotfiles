HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT="%F %T "

if command -v hx >/dev/null; then
  EDITOR=hx
elif command -v nvim >/dev/null; then
  EDITOR=nvim
elif command -v vim >/dev/null; then
  EDITOR=vim
elif command -v code >/dev/null; then
  EDITOR=code
else
  echo >&2 "WARN: EDITOR not found"
  EDITOR="${EDITOR:-vi}"
fi

export EDITOR
export VISUAL="${VISUAL:-$EDITOR}"
