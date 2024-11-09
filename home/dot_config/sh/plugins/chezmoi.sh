if hash c 2>/dev/null; then
  return
fi

c() {
  if [ $# -eq 0 ]; then
    chezmoi status
  else
    chezmoi "$@"
  fi
}

if [ -f /usr/share/bash-completion/completions/chezmoi ]; then
  source /usr/share/bash-completion/completions/chezmoi
  complete -o default -F __start_chezmoi c
fi
