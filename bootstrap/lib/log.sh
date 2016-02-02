#!/usr/bin/env bash

# log.sh

import "lib/colors"

print() {
	printf "%s\r\n" "$@"
}

_print() {
	local color=$1
	local symbol=$2
	local title=$3
	local message=$4

	local col=$(( $(tput cols) / 4 ))

	printf "$(now)${color}%s %-${col}s${nc} %s\r\n" "$symbol" "$title" "$message"
}

log() {
	local title=$1; shift
	local msg=$@

	_print $nc ">" "$title" "$msg"
}

log_debug() {
	local title=$1; shift
	local msg=$@
	if [[ "$DEBUG" = true ]]; then
		_print $purple "*" "$title" "$msg"
	fi
}

log_error() {
	local title=$1; shift
	local msg=$@

	_print $red "x" "$title" "$msg"
}

log_info() {
	local title=$1; shift
	local msg=$@

	_print $blue "i" "$title" "$msg"
}

log_success() {
	local title=$1; shift
	local msg=$@

	_print $green "v" "$title" "$msg"
}

log_warn() {
	local title=$1; shift
	local msg=$@

	_print $yellow "!" "$title" "$msg"
}

now() {
	local date=""

	[[ ! -z "${TIMESTAMPS-}" ]] && \
		[[ "$TIMESTAMPS" = true ]] && \
		date="[$(date +%H:%M:%S)] "

	printf "%s" "$date"
}
