#!/usr/bin/env bash

# log.sh

import "lib/colors"
import "lib/utils" # now()

log() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $reset " " "${msg}${reset}" "$txt" "$cr"
}

log_ask() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $blue " " "${msg}?${reset}" "$txt" "$cr"
}

log_debug() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	if [[ "${DEBUG-}" = true ]]; then
		_print $cyan "*" "${msg}${reset}" "$txt" "$cr"
	fi
}

log_error() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# × ✕ ✖ ✗ ✘
	_print $red "✘" "${msg}${reset}" "$txt" "$cr"
}

log_info() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $white "›" "${msg}${reset}" "$txt" "$cr"
}

log_success() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# ✓ ✔
	_print $green "✓" "${msg}${reset}" "$txt" "$cr"
}

log_warn() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# ⚠ !
	_print $yellow "!" "${msg}${reset}" "$txt" "$cr"
}

print() {
	printf "%s\r\n" "$@"
}

_print() {
	local color #=$1
	local symbol=$2
	local message=$3
	local text=$4
	local cr=$5

	# Messages starting with "**"
	if [[ "$message" =~ \*\**  ]]; then
		message=${message#\*\*} # Remove prefix '**'
		color="${bold}" # Make the message bold
	else
		color="${reset}"
	fi

	local col=$(( $(tput cols) / 4 ))

	printf "$(now)${color}${1}%b %-${col}b %b$cr" "$symbol" "$message" "$text"
}
