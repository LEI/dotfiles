# Allow aliases with sudo
alias sudo="sudo "

# Confirm before overwriting
alias cp="cp --interactive"

# Print sizes in powers of 1024
alias df="df -h" # --human-readable

# Show with human-readable units
alias free="free --human"

# Color matches
alias grep="grep --color=auto"

# List all files with colors, human-readable sizes and long format
alias la="ls -ahl --color=auto"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Reload the shell (i.e. invoke as a login shell)
alias reload='exec ${SHELL} -l'

if command -v bat >/dev/null; then
  alias cat=bat
fi
alias e=editor
alias o=open

# TODO: termux-open
if ! hash open 2>/dev/null; then
  if [ -f /proc/version ] && grep -q Microsoft /proc/version; then
    alias open=explorer.exe
  else
    alias open=xdg-open
  fi
fi
