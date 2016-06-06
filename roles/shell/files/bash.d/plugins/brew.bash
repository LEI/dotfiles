# Homebrew

[[ "$(uname -s)" == "Darwin" ]] || return

# Disable Google Analytics
HOMEBREW_NO_ANALYTICS=1

# Change default location of Homebrew Cask applications
HOMEBREW_CASK_OPTS="--appdir=/Applications" #--caskroom=/etc/Caskroom

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
