if hash c 2>/dev/null && [ -f /usr/share/bash-completion/completions/chezmoi ]; then
  source /usr/share/bash-completion/completions/chezmoi
  complete -o default -F __start_chezmoi c
fi
