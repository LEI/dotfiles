#
# Bash utils
#

# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile
# https://github.com/mathiasbynens/dotfiles/blob/master/.functions
# https://github.com/Bash-it/bash-it/blob/master/lib/helpers.bash
# https://github.com/Bash-it/bash-it/blob/master/plugins/available/base.plugin.bash

# Use the directory where this file is stored if $BASH_DIR is not defined
export BASH_DIR="${BASH_DIR:-$(dirname "$BASH_SOURCE")}"
# export BASH_DIR="$HOME/.bash.d"

lib() {
  source_file "$BASH_DIR/library/$1"
}

add() {
  for dir in "$@"; do
    case $dir in
      # colors)
      #   source_file $BASH_DIR/theme/colors.bash
      #   ;;
      aliases|completion|library|plugins|*)
        source_bash "$BASH_DIR/$dir"
        ;;
    esac
  done
  unset dir
}

source_bash() {
  local directory="$1"

  if [[ -d "$directory" ]]; then
    source_file $directory/*.bash
  else
    echo >&2 "Not a directory: $directory"
    return 1
  fi
}

source_files() {
  for file in "$@"; do
    source_file "$file"
  done
  unset file
}

source_file() {
  local file="$1"
  if [[ -r "$file" ]] && [[ -f "$file" ]]; then
    source "$file"
  # else
  #   echo >&2 "Could not source $file"
  fi
}
