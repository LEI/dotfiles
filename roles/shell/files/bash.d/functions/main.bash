# General functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

# Test if a command exists
has() {
  hash "$1" 2>/dev/null
}

mkd() {
  mkdir -p -- "$*"
}

mkcd() {
  mkd "$*" && cd -- "$*"
}

del() {
  local trash="/tmp/.trash"
  mkd "$trash" && mv "$*" "$trash"
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
  # TODO source ~/.bashrc instead?
  # Invoke as a login shell
  exec $SHELL -l
}
