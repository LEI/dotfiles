#
# Bash completion
#

# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile

# Add tab completion for many Bash commands
if which brew &> /dev/null && [[ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion"
# elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
#   source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Force git completion?
if ! type _git &> /dev/null; then
  if [[ -f /usr/share/bash-completion/completions/git ]]; then
    source /usr/share/bash-completion/completions/git
  fi
fi

# Enable tab completion for 'g' by marking it as an alias for 'git'
if type __git_complete &> /dev/null && type __git_main &> /dev/null; then
  # [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
  # complete -o default -o nospace -F _git g
  __git_complete g __git_main
fi

# type _git

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
