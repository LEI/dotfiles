# shellcheck shell=bash

pathmunge() {
  if [ -z "$1" ] || [ ! -d "$1" ]; then
    return 1
  fi
  # Skip if already in PATH (unless replacing)
  # Not required with ZSH typeset -U path
  case ":$PATH:" in
  *:"$1":*)
    if [ "${2:-}" = replace ]; then
      PATH="${PATH//:$1/}"
      PATH="${PATH//$1:/}"
    else
      return 2
    fi
    ;;
  esac
  if [ "${2:-}" = after ]; then
    PATH="$PATH:$1"
  else
    PATH="$1:$PATH"
  fi
}
