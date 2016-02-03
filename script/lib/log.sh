#!/usr/bin/env bash

# log.sh

import "colors"

log() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $nc " " "$msg" "$txt" "$cr"
}

log_ask() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $yellow "?" "$msg" "$txt" "$cr"
}

log_debug() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	if [[ "${DOT_CONFIG_DEBUG-}" = true ]]; then
		_print $purple "*" "$msg" "$txt" "$cr"
	fi
}

log_error() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# × ✕ ✖ ✗ ✘
	_print $red "✘" "$msg" "$txt" "$cr"
}

log_info() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $blue "›" "$msg" "$txt" "$cr"
}

log_exec() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}

	_print $purple ">" "$msg" "$txt" "$cr"
}

log_success() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# ✓ ✔
	_print $green "✓" "$msg" "$txt" "$cr"
}

log_warn() {
	local msg=$1
	local txt=${2-}
	local cr=${3-"\r\n"}
	# ⚠ !
	_print $yellow "!" "$msg" "$txt" "$cr"
}

print() {
	printf "%s\r\n" "$@"
}

_print() {
	local color=$1
	local symbol=$2
	local message=$3
	local text=$4
	local cr=$5

	local col=$(( $(tput cols) / 4 ))

	printf "$(now)${color}%b %-${col}s${nc} %s$cr" "$symbol" "$message" "$text"
}

now() {
	local date=""

	[[ ! -z "${DOT_CONFIG_TIMESTAMPS-}" ]] && \
		[[ "$DOT_CONFIG_TIMESTAMPS" = true ]] && \
		date="[$(date +%H:%M:%S)] "

	printf "%s" "$date"
}
