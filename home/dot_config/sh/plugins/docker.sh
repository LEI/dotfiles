if hash d 2>/dev/null; then
  return
fi

d() {
  if [ $# -eq 0 ]; then
    docker ps --all
  else
    docker "$@"
  fi
}

# FIXME(codespaces): syntax error near unexpected token `)'
if [ "${CODESPACES:-}" != "true" ] && [ -f /usr/share/bash-completion/completions/docker ]; then
  source /usr/share/bash-completion/completions/docker
  complete -o default -F __start_docker d
fi
