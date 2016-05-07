#
# Bash init
#

# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile
# https://github.com/mathiasbynens/dotfiles/blob/master/.functions
# https://github.com/Bash-it/bash-it/blob/master/lib/helpers.bash
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

# Use the directory where this file is stored if $BASH_DIR is not defined
export BASH_DIR="${BASH_DIR:-$(dirname "$BASH_SOURCE")}"
# export BASH_DIR="$HOME/.bash.d"

add() {
  cd "$BASH_DIR"

  for dir in "$@"; do
    case $dir in
      colors)
        source theme/colors.bash
        ;;
      aliases|completion|library|plugins)
        bash_load "$dir"
        ;;
      *)
        echo "Unknown module: $dir"
        return 1
        ;;
    esac
  done
  unset dir
}

bash_load() {
  local directory="$1"

  if [[ -d "$directory" ]]; then
    load $directory/*.bash
  else
    echo >&2 "Not a directory: $directory"
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
