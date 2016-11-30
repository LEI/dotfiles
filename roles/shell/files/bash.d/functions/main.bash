# General functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

# Make a directory and change into it
mkd() {
  mkdir -p "$1" && cd "$_"
}

# Move files in trash to be removed
del() {
  local trash="/tmp/.trash"
  mkdir -p "$trash" && mv "$*" "$trash"
}

# Preview markdown
pmd() {
  if has markdown; then
    markdown "$1"
  fi
}

down4me() {
  curl -s "http://www.downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}

reload() {
  # Invoke as a login shell
  # exec $SHELL -l

  source "$HOME/.bashrc"

  # Reload readline
  # bind -f ~/.inputrc
}
