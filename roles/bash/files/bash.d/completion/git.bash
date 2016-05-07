#
# Git completion
#

# Try to source git completion if there is no _git function
if ! type _git &>/dev/null; then
  if [[ -f /usr/share/bash-completion/completions/git ]]; then
    source /usr/share/bash-completion/completions/git
  fi
fi

# Enable tab completion for 'g' by marking it as an alias for 'git'
if type __git_complete &>/dev/null && type __git_main &>/dev/null; then
  # [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
  # complete -o default -o nospace -F _git g
  __git_complete g __git_main
fi
