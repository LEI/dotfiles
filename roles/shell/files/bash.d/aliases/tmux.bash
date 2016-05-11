# Attach to session or create one
alias t='[[ "$#" -eq 0 ]] && tmux attach || tmux "$@"'
