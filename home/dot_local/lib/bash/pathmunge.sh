# shellcheck shell=bash

pathmunge() {
  if [ -z "$1" ] || [ ! -d "$1" ]; then
    return 1
  fi
  # Match Fedora /etc/profile: silent no-op when already in PATH
  # Not required with ZSH typeset -U path
  case ":$PATH:" in
  *:"$1":*)
    if [ "${2:-}" = replace ]; then
      PATH="${PATH//:$1/}"
      PATH="${PATH//$1:/}"
    else
      return 0
    fi
    ;;
  esac
  if [ "${2:-}" = after ]; then
    PATH="$PATH:$1"
  else
    PATH="$1:$PATH"
  fi
}
