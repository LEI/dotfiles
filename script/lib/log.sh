#!/usr/bin/env bash

# log.sh

import "lib/colors"
import "lib/utils" # now()

log() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}

  _print $reset " " "${msg}" "$txt" "$cr"
}

log_ask() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}

  _print $blue " " "${msg}?" "$txt" "$cr"
}

log_debug() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}

  if [[ "${DEBUG-}" = true ]]; then
    _print $cyan "*" "${msg}" "$txt" "$cr"
  fi
}

log_error() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}
  # × ✕ ✖ ✗ ✘
  _print $red "✘" "${msg}" "$txt" "$cr"
}

log_info() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}

  _print $white "›" "${msg}" "$txt" "$cr"
}

log_success() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}
  # ✓ ✔
  _print $green "✓" "${msg}" "$txt" "$cr"
}

log_warn() {
  local msg=$1
  local txt=${2-}
  local cr=${3-"\r\n"}
  # ⚠ !
  _print $yellow "!" "${msg}" "$txt" "$cr"
}

print() {
  printf "%s\r\n" "$@"
}

# TODO: no color option
_print() {
  local color=$1
  local symbol=$2
  local message=$3
  local text=$4
  local cr=$5
  # Highlight
  local hi=

  # Transform messages starting with "**"
  if [[ "$message" =~ ^\*\**  ]]; then
    message=${message#\*\*} # Remove prefix '**'
    hi="${bold}" # Make the message bold
  fi

  # Identation
  local ind=$(( 2 * 1 ))
  # Tabulation
  local col=$(( $(tput cols) / 3 ))

  local align=""
  printf "$(now)${hi}${color}%${ind}s%b  %-${col}b${reset} %b$cr" "" "$symbol" "$message" "$text"
}
