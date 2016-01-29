#!/bin/bash
# logger.sh

# . dot/lib/colors.sh

ask() {
	log $cyan "?" "$@"
}

info() {
	# ›
	log $blue "›" "$@"
}

success() {
	# ✓ ✔
	log $green "✓" "$@"
}

error() {
	# × ✕ ✖ ✗ ✘
	log $red "✗" "$@" #
}

warn() {
	# ⚠
	log $yellow "⚠" "$@"
}

debug() {
	# 🐞
	if [[ "$DEBUG" = true ]]; then
		log $cyan "*" "$@"
	fi
}

log() {
	local color=$1
	local symbol=$2 # log level
	local message=$3
	local eol=${4-"\r\n"}

	printf "[$(date +%H:%M:%S)]  $color%b$end\t%s$eol" "$symbol" "$message"
	# local date=$(date +%Y/%m/%d%H:%M:%S)
	# echo -e "[$date] $@" >&2
}
