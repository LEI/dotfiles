#
# Git completion
#

# Try to source git completion if there is no _git function
if ! hash _git 2>/dev/null; then
  if [[ -f /usr/share/bash-completion/completions/git ]]; then
    source /usr/share/bash-completion/completions/git
  elif [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
    source /usr/local/etc/bash_completion.d/git-completion.bash
  fi
fi

# Enable tab completion for 'g' by marking it as an alias for 'git'
if hash __git_complete 2>/dev/null && hash __git_main 2>/dev/null; then
  # [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
  # complete -o default -o nospace -F _git g
  __git_complete g __git_main
fi
