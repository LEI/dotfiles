# # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# if [[ -e "$HOME/.ssh/config" ]]; then # [[ -d "$HOME/.ssh/config.d" ]]
#   complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
# fi

# source /etc/bash_completion
# source /etc/profile.d/bash_completion.sh
if [ -r /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi

if hash c 2>/dev/null && [ -f /usr/share/bash-completion/completions/chezmoi ]; then
  source /usr/share/bash-completion/completions/chezmoi
  complete -o default -F __start_chezmoi c
fi

# FIXME(codespaces): syntax error near unexpected token `)'
if [ "${CODESPACES:-}" != "true" ] &&
  hash d 2>/dev/null && [ -f /usr/share/bash-completion/completions/docker ]; then
  source /usr/share/bash-completion/completions/docker
  complete -o default -F __start_docker d
fi

# _completion_loader git
# # complete -F _git g
# # https://stackoverflow.com/a/24665529/7796750
# if hash __git_complete 2>/dev/null; then
#   __git_complete g __git_main
# fi
if hash g 2>/dev/null && [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
  __git_complete g __git_main
fi

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
if hash k 2>/dev/null; then
  if [ -f /usr/share/bash-completion/completions/kubectl ]; then
    source /usr/share/bash-completion/completions/kubectl
    complete -o default -F __start_kubectl k
  elif hash _kubectl_completion 2>/dev/null; then
    complete -o noquote -F _kubectl_completion k
  fi
fi

# https://carapace-sh.github.io/carapace-bin/setup.html#bash
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
if command -v carapace >/dev/null; then
  # shellcheck disable=SC1090
  source <(carapace _carapace)
fi
