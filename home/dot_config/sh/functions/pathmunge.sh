pathmunge() {
  if [ -z "$1" ] || [ ! -d "$1" ]; then
    # Not a directory
    return 1
  fi
  # This check is not required if running ZSH with typeset -U path
  # It should even be removed if it allows to change the position
  # of existing directories in PATH (before/after)
  case ":$PATH:" in
  *:"$1":*)
    # Force replacement
    if [ "${3:-}" = replace ]; then
      PATH="${PATH//:$1/}"
      PATH="${PATH//$1:/}"
    else
      return 2
    fi
    ;;
  esac
  # Bash: [[ $PATH =~ (^|:)$p($|:) ]]
  # Add the new directory to the beginning or to the end of PATH
  if [ "$2" = "before" ]; then
    # pathmunge /path/to/dir
    PATH="$1:$PATH"
  else
    # pathmunge /path/to/dir after
    PATH="$PATH:$1"
  fi
}
