#
# Bash init
#

# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile
# https://github.com/mathiasbynens/dotfiles/blob/master/.functions
# https://github.com/Bash-it/bash-it/blob/master/lib/helpers.bash
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

export BASH_DIR="$HOME/.bash.d"

# for file in $BASH_DIR/{aliases,completion,library,plugins}/*.bash; do
#   if [[ -r "$file" ]] && [[ -f "$file" ]]; then
#     source "$file"
#   fi
# done
# source ~/.bash.d/loader.bash
# init() {
#   bash_load aliases
#   bash_load library
#   bash_load plugins
# }

add() {
  for dir in "$@"; do
    case $dir in
      colors)
        source ~/.bash.d/theme/colors.bash
        ;;
      aliases|completion|library|plugins)
        bash_load "$dir"
        ;;
      *)
        echo "Unknown directory: $dir"
        return 1
        ;;
    esac
  done
  unset dir
}

bash_load() {
  # Use the directory where this file is stored if $BASH_DIR is not defined
  local directory="${BASH_DIR:-$(dirname "$BASH_SOURCE")}/$1"

  if [[ -d "$directory" ]]; then
    load $directory/*.bash
  else
    echo >&2 "Could not find $directory"
    return 1
  fi
}

load() {
  for file in "$@"; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
      source "$file"
    # else
    #   echo >&2 "Could not source $file"
    fi
  done
  unset file
}
