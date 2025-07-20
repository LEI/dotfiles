# FIXME(codespaces): syntax error near unexpected token `)'
if [ "${CODESPACES:-}" != "true" ] &&
  hash d 2>/dev/null && [ -f /usr/share/bash-completion/completions/docker ]; then
  source /usr/share/bash-completion/completions/docker
  complete -o default -F __start_docker d
fi
