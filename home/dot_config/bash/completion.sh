# # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
# if [[ -e "$HOME/.ssh/config" ]]; then # [[ -d "$HOME/.ssh/config.d" ]]
#   complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
# fi

# source /etc/bash_completion
# source /etc/profile.d/bash_completion.sh
if [ -r /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi

# # https://carapace-sh.github.io/carapace-bin/setup.html#bash
# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# # shellcheck disable=SC1090
# source <(carapace _carapace)
