# # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# if [[ -e "$HOME/.ssh/config" ]]; then # [[ -d "$HOME/.ssh/config.d" ]]
#   complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
# fi

# COMPLETION_PREFIX=""
# if command -v brew >/dev/null; then
#   COMPLETION_PREFIX="$(brew --prefix)"
# fi
# if [ -f "$COMPLETION_PREFIX/etc/bash_completion" ]; then
#   source "$COMPLETION_PREFIX/etc/bash_completion"
# fi
# if [ -f "$COMPLETION_PREFIX/etc/profile.d/bash_completion.sh" ]; then
#   source "$COMPLETION_PREFIX/etc/profile.d/bash_completion.sh"
# fi
# if [ -f "$COMPLETION_PREFIX/etc/share/bash-completion" ]; then
#   source "$COMPLETION_PREFIX/etc/share/bash-completion"
# fi

# if hash c 2>/dev/null && [ -f /usr/share/bash-completion/completions/chezmoi ]; then
#   source /usr/share/bash-completion/completions/chezmoi
#   complete -o default -F __start_chezmoi c
# fi

# # if command -v docker >/dev/null && [ ! -f "$COMPLETION_PREFIX/etc/bash_completion.d/docker" ]; then
# #   cmd docker completion bash >"$COMPLETION_PREFIX/etc/bash_completion.d/docker"
# # fi
# if [ -f /usr/share/bash-completion/completions/docker ]; then
#   cmd source /usr/share/bash-completion/completions/docker
# fi

# # https://docs.docker.com/engine/cli/completion/
# # FIXME(codespaces): syntax error near unexpected token `)'
# if [ "${CODESPACES:-}" != "true" ] && hash d 2>/dev/null && hash __start_docker 2>/dev/null; then
#   complete -o default -F __start_docker d
# fi

# # _completion_loader git
# # # complete -F _git g
# # # https://stackoverflow.com/a/24665529/7796750
# # if hash __git_complete 2>/dev/null; then
# #   __git_complete g __git_main
# # fi
# if hash g 2>/dev/null && [ -f /usr/share/bash-completion/completions/git ]; then
#   source /usr/share/bash-completion/completions/git
#   __git_complete g __git_main
# fi

# # https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
# if hash k 2>/dev/null; then
#   if [ -f /usr/share/bash-completion/completions/kubectl ]; then
#     source /usr/share/bash-completion/completions/kubectl
#     complete -o default -F __start_kubectl k
#   elif hash _kubectl_completion 2>/dev/null; then
#     complete -o noquote -F _kubectl_completion k
#   fi
# fi
