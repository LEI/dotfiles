#
# OS X completion
#

# https://github.com/Bash-it/bash-it/blob/master/completion/available/system.completion.bash

[[ "$(uname -s)" == "Darwin" ]] || return

# Add tab completion for brew commands
if hash brew 2>/dev/null; then
  BREW_PREFIX=$(brew --prefix)
  # /usr/local/share/bash-completion/completion/* ?
  if [[ -f "$BREW_PREFIX/share/bash-completion/bash_completion" ]]; then
    source "$BREW_PREFIX/share/bash-completion/bash_completion"
  # elif [[ -f "$BREW_PREFIX/etc/bash_completion" ]]; then
  #   source "$BREW_PREFIX/etc/bash_completion"
  fi
fi

# Add tab completion for 'defaults read|write NSGlobalDomain' (or '-g')
complete -W "NSGlobalDomain" defaults

# Add 'killall' tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
