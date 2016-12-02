# General functions
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

mkd() {
  mkdir -p "$1"
}

mcd() {
  mkdir -p "$1" && cd "$_"
}

# Move files in trash to be removed
del() {
  local trash="/tmp/.trash"
  mkdir -p "$trash" && mv "$*" "$trash"
}

if ! hash pager 2>/dev/null
then pager() { "${PAGER:-less}"; }
fi
dif() {
  diff --side-by-side "$@" | pager
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
