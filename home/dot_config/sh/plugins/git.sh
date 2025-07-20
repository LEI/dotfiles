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
