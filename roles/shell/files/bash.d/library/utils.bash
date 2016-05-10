#!/usr/bin/env bash
#
# Bash utils
#

# Test if a command is available
has() {
  hash "$1" 2>/dev/null
}

# Source a list of path
_source() {
  for path in "$@"; do
    if [[ -d "$path" ]]; then
      _source $path/*
    elif [[ -f "$path" ]]; then
      source "$path"
    else
      echo >&2 "No such file or directory: $path"
    fi
  done
  unset path
}
