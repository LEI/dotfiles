#
# System completion
#

# Aliases completion?
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/alias-completion.plugin.bash

# Add tab completion for many Bash commands?
# if [[ -f /usr/share/bash-completion/bash_completion ]]; then
#   source /usr/share/bash-completion/bash_completion
# elif [[ -f /etc/bash_completion ]]; then # See ~/.bash_completion
#   source /etc/bash_completion # .d?
# fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
if [[ -e "$HOME/.ssh/config" ]]; then
  complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
fi
